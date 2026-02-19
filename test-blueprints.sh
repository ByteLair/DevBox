#!/bin/bash
# DevBox v1.2 - Test Suite
# Tests all 12 blueprints sequentially
# Uses SSH ControlMaster to share a single TCP connection per blueprint
# (avoids triggering the iptables SSH rate-limit of 5 new connections / 60s)

set -uo pipefail

SSH_KEY="$(cat ~/.ssh/id_ed25519.pub 2>/dev/null || cat ~/.ssh/id_rsa.pub)"
PASS=0
FAIL=0
SKIP=0
RESULTS=()

# Temporary socket directory for ControlMaster sockets
SOCK_DIR="$(mktemp -d /tmp/devbox-test-XXXXX)"
trap 'rm -rf "$SOCK_DIR"' EXIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log()    { echo -e "${BLUE}[TEST]${NC} $*"; }
pass()   { echo -e "  ${GREEN}✅ PASS${NC} $*"; ((PASS++)); }
fail()   { echo -e "  ${RED}❌ FAIL${NC} $*"; ((FAIL++)); }
skip()   { echo -e "  ${YELLOW}⏭  SKIP${NC} $*"; ((SKIP++)); }
header() { echo -e "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BOLD}  $*${NC}"; echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ──────────────────────────────────────────
# SSH helpers — all reuse the ControlMaster socket
# ──────────────────────────────────────────

# Run a command through the existing master socket
ssh_run() {
    local sock=$1; shift
    ssh -o StrictHostKeyChecking=no \
        -o BatchMode=yes \
        -o ControlMaster=no \
        -o ControlPath="$sock" \
        developer@localhost "$@"
}

# Run a login-shell command (sources /etc/profile, ~/.profile, PATH, etc.)
ssh_login() {
    local sock=$1; shift
    local cmd="$*"
    ssh_run "$sock" "bash -lc $(printf '%q' "$cmd")"
}

# Close the master connection
ssh_master_close() {
    local sock=$1
    ssh -o ControlPath="$sock" -O exit developer@localhost 2>/dev/null || true
}

# ──────────────────────────────────────────
test_blueprint() {
    local name=$1
    local port=$2
    local image="lyskdot/devbox-${name}:1.2"
    local container="test-${name}"
    local sock=""
    local result="PASS"

    header "Blueprint: ${name} (port ${port})"

    # Cleanup any existing container + stale known_hosts entry
    docker rm -f "$container" >/dev/null 2>&1 || true
    ssh-keygen -f ~/.ssh/known_hosts -R "[localhost]:${port}" >/dev/null 2>&1 || true

    # --- TEST 1: Image exists locally ---
    log "Image exists locally"
    if docker image inspect "$image" >/dev/null 2>&1; then
        pass "Image ${image} found"
    else
        fail "Image ${image} not found — skipping blueprint"
        RESULTS+=("${name}: ❌ IMAGE_MISSING")
        return
    fi

    # --- TEST 2: Container starts ---
    log "Container startup"
    docker run -d \
        --name "$container" \
        -p "${port}:22" \
        --cap-add=NET_ADMIN \
        -e SSH_PUBLIC_KEY="$SSH_KEY" \
        "$image" >/dev/null 2>&1

    local started=false
    for i in $(seq 1 20); do
        local status
        status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "error")
        if [[ "$status" == "running" ]]; then started=true; break; fi
        if [[ "$status" == "exited" || "$status" == "dead" ]]; then break; fi
        sleep 1
    done

    if $started; then
        pass "Container started (status: running)"
    else
        fail "Container failed to start (status: ${status:-unknown})"
        docker logs "$container" 2>&1 | tail -10 | sed 's/^/    /'
        docker rm -f "$container" >/dev/null 2>&1 || true
        RESULTS+=("${name}: ❌ STARTUP_FAILED")
        return
    fi

    # --- TEST 3: Open master SSH connection (up to 30s, single connection attempt per loop) ---
    log "SSH connectivity (ControlMaster)"
    local cm_sock="${SOCK_DIR}/ctl-${port}"
    local ssh_ok=false

    for i in $(seq 1 30); do
        if ssh -o StrictHostKeyChecking=no \
               -o ConnectTimeout=3 \
               -o BatchMode=yes \
               -o ControlMaster=yes \
               -o ControlPath="$cm_sock" \
               -o ControlPersist=300 \
               -o ServerAliveInterval=3 \
               -o ServerAliveCountMax=2 \
               -p "$port" developer@localhost \
               -fN 2>/dev/null; then
            ssh_ok=true; break
        fi
        sleep 1
    done

    if $ssh_ok; then
        pass "SSH ControlMaster connection established"
        sock="$cm_sock"
    else
        fail "SSH connection failed after 30s"
        docker logs "$container" 2>&1 | tail -5 | sed 's/^/    /'
        docker rm -f "$container" >/dev/null 2>&1 || true
        RESULTS+=("${name}: ❌ SSH_FAILED")
        return
    fi

    # Local helpers that bind the socket
    run_cmd() { ssh_run "$sock" "$@"; }
    run_t()   { ssh_login "$sock" "$@" >/dev/null 2>&1; }

    # --- TEST 4: User and home directory ---
    log "User 'developer' and home directory"
    local whoami_out; whoami_out=$(run_cmd "whoami" 2>/dev/null || echo "")
    local home_ok=false
    run_cmd "ls /home/developer" >/dev/null 2>/dev/null && home_ok=true

    if [[ "$whoami_out" == "developer" ]]; then
        pass "User is 'developer'"
    else
        fail "User is '${whoami_out}' (expected 'developer')"
        result="FAIL"
    fi
    if $home_ok; then
        pass "/home/developer exists"
    else
        fail "/home/developer not accessible"
        result="FAIL"
    fi

    # --- TEST 5: SSH key auth ---
    log "SSH key authentication"
    local key_out; key_out=$(run_cmd "echo key_auth_ok" 2>/dev/null || echo "")
    if [[ "$key_out" == "key_auth_ok" ]]; then
        pass "SSH key auth working"
    else
        fail "SSH key auth failed"
        result="FAIL"
    fi

    # --- TEST 6: HEALTHCHECK directive ---
    log "HEALTHCHECK directive"
    local health; health=$(docker inspect --format='{{.Config.Healthcheck}}' "$container" 2>/dev/null || echo "")
    if [[ -n "$health" && "$health" != "<nil>" ]]; then
        pass "HEALTHCHECK configured"
    else
        fail "HEALTHCHECK not set"
        result="FAIL"
    fi

    # --- TEST 7: Environment variables ---
    log "Environment variables (TZ, LANG)"
    local tz;   tz=$(run_cmd   'echo $TZ'   2>/dev/null || echo "")
    local lang; lang=$(run_cmd 'echo $LANG' 2>/dev/null || echo "")
    if [[ "$tz" == "UTC" ]]; then
        pass "TZ=UTC"
    else
        fail "TZ='${tz}' (expected UTC)"
        result="FAIL"
    fi
    if [[ "$lang" == "en_US.UTF-8" ]]; then
        pass "LANG=en_US.UTF-8"
    else
        fail "LANG='${lang}' (expected en_US.UTF-8)"
        result="FAIL"
    fi

    # --- TEST 8: Audit log directory ---
    log "Audit log directory"
    if run_cmd 'test -d /var/log/devbox' 2>/dev/null; then
        pass "/var/log/devbox exists"
    else
        fail "/var/log/devbox not found"
        result="FAIL"
    fi

    # --- TEST 9: Blueprint-specific tools ---
    log "Blueprint-specific tools"
    case "$name" in
        python)
            run_t "python3 --version"    && pass "python3 available" || { fail "python3 missing"; result="FAIL"; }
            run_t "pip3 --version"       && pass "pip3 available"    || { fail "pip3 missing";    result="FAIL"; }
            run_t "jupyter --version"    && pass "jupyter available" || { fail "jupyter missing"; result="FAIL"; }
            ;;
        node)
            run_t "node --version"       && pass "node available"    || { fail "node missing";    result="FAIL"; }
            run_t "npm --version"        && pass "npm available"     || { fail "npm missing";     result="FAIL"; }
            run_t "which yarn"           && pass "yarn available"    || { fail "yarn missing";    result="FAIL"; }
            ;;
        fullstack)
            run_t "node --version"       && pass "node available"    || { fail "node missing";    result="FAIL"; }
            run_t "python3 --version"    && pass "python3 available" || { fail "python3 missing"; result="FAIL"; }
            run_t "psql --version"       && pass "psql available"    || { fail "psql missing";    result="FAIL"; }
            ;;
        web)
            run_t "node --version"       && pass "node available"    || { fail "node missing";    result="FAIL"; }
            run_t "npm --version"        && pass "npm available"     || { fail "npm missing";     result="FAIL"; }
            ;;
        devops)
            run_t "terraform --version"  && pass "terraform available" || { fail "terraform missing"; result="FAIL"; }
            run_t "kubectl version --client 2>/dev/null || kubectl version --client --output=yaml 2>/dev/null" \
                                         && pass "kubectl available"   || { fail "kubectl missing";   result="FAIL"; }
            run_t "ansible --version"    && pass "ansible available"   || { fail "ansible missing";   result="FAIL"; }
            run_t "helm version"         && pass "helm available"      || { fail "helm missing";      result="FAIL"; }
            ;;
        go)
            run_t "go version"           && pass "go available"     || { fail "go missing";     result="FAIL"; }
            run_t "which gopls"          && pass "gopls available"  || { fail "gopls missing";  result="FAIL"; }
            run_t "which dlv"            && pass "delve available"  || { fail "delve missing";  result="FAIL"; }
            ;;
        php)
            run_t "php --version"        && pass "php available"      || { fail "php missing";      result="FAIL"; }
            run_t "composer --version"   && pass "composer available" || { fail "composer missing"; result="FAIL"; }
            ;;
        java)
            run_t "java --version"       && pass "java available"   || { fail "java missing";   result="FAIL"; }
            run_t "mvn --version"        && pass "maven available"  || { fail "maven missing";  result="FAIL"; }
            run_t "gradle --version"     && pass "gradle available" || { fail "gradle missing"; result="FAIL"; }
            ;;
    esac

    # --- TEST 10: sudo access ---
    log "sudo access (passwordless)"
    local sudo_out; sudo_out=$(run_cmd "sudo -n whoami" 2>/dev/null || echo "")
    if [[ "$sudo_out" == "root" ]]; then
        pass "sudo passwordless working"
    else
        fail "sudo failed (got: '${sudo_out}')"
        result="FAIL"
    fi

    # Close master connection and clean up container
    ssh_master_close "$sock" 2>/dev/null || true
    docker rm -f "$container" >/dev/null 2>&1 || true

    RESULTS+=("${name}: ${result}")
    echo ""
}

# ──────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────
echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════╗"
echo "║     DevBox v1.2 - Full Test Suite (8 blueprints)   ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Started: $(date)"
echo "SSH Key: ${SSH_KEY:0:40}..."
echo ""

# Kill any leftover test containers
docker rm -f $(docker ps -aq --filter "name=test-") >/dev/null 2>&1 || true

# Run each blueprint test sequentially (8 blueprints)
test_blueprint "python"    3100
test_blueprint "node"      3101
test_blueprint "fullstack" 3102
test_blueprint "web"       3103
test_blueprint "devops"    3104
test_blueprint "go"        3105
test_blueprint "php"       3106
test_blueprint "java"      3107

# ──────────────────────────────────────────
# SUMMARY
# ──────────────────────────────────────────
TOTAL=$((PASS + FAIL + SKIP))
header "📊 Test Summary"
echo ""
for r in "${RESULTS[@]}"; do
    if [[ "$r" == *": PASS"* ]]; then
        echo -e "  ${GREEN}✅${NC} $r"
    else
        echo -e "  ${RED}❌${NC} $r"
    fi
done
echo ""
echo -e "  Tests run:    ${TOTAL}"
echo -e "  ${GREEN}Passed:${NC}       ${PASS}"
echo -e "  ${RED}Failed:${NC}       ${FAIL}"
echo -e "  ${YELLOW}Skipped:${NC}      ${SKIP}"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}  🎉 ALL TESTS PASSED!${NC}"
else
    echo -e "${RED}${BOLD}  ⚠️  ${FAIL} TEST(S) FAILED${NC}"
fi
echo ""
echo "Finished: $(date)"

exit $([[ $FAIL -eq 0 ]] && echo 0 || echo 1)
