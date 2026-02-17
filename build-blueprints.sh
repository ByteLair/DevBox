#!/bin/bash
set -e

# ByteLair DevBox - Build All Blueprints Script
# This script builds all Docker images for the blueprints

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Docker Hub username
DOCKER_USER="lyskdot"
VERSION="1.1.0"

# Blueprint list
BLUEPRINTS=(
    "minimal"
    "python"
    "node"
    "fullstack"
    "web"
    "ml"
    "devops"
    "go"
    "rust"
    "php"
    "ruby"
    "java"
)

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   ByteLair DevBox - Blueprint Builder     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Copy entrypoint.sh to each blueprint directory
echo -e "${YELLOW}📋 Preparing blueprint directories...${NC}"
for blueprint in "${BLUEPRINTS[@]}"; do
    if [ "$blueprint" != "minimal" ]; then
        cp entrypoint.sh blueprints/$blueprint/
        echo -e "${GREEN}✓${NC} Copied entrypoint.sh to blueprints/$blueprint/"
    fi
done

# Build option
BUILD_MODE="${1:-all}"

if [ "$BUILD_MODE" == "push" ]; then
    echo -e "${YELLOW}🚀 Building and pushing all blueprints to Docker Hub...${NC}"
else
    echo -e "${YELLOW}🔨 Building all blueprints locally...${NC}"
fi

echo ""

# Build each blueprint
for blueprint in "${BLUEPRINTS[@]}"; do
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Building: ${blueprint}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    cd blueprints/$blueprint
    
    # Build the image with multiple tags
    docker build \
        -t ${DOCKER_USER}/devbox-${blueprint}:latest \
        -t ${DOCKER_USER}/devbox-${blueprint}:${VERSION} \
        -t ${DOCKER_USER}/devbox-${blueprint}:1.1 \
        -t ${DOCKER_USER}/devbox-${blueprint}:1 \
        .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully built devbox-${blueprint}${NC}"
        
        # Push if requested
        if [ "$BUILD_MODE" == "push" ]; then
            echo -e "${YELLOW}📤 Pushing devbox-${blueprint} to Docker Hub...${NC}"
            docker push ${DOCKER_USER}/devbox-${blueprint}:latest
            docker push ${DOCKER_USER}/devbox-${blueprint}:${VERSION}
            docker push ${DOCKER_USER}/devbox-${blueprint}:1.1
            docker push ${DOCKER_USER}/devbox-${blueprint}:1
            echo -e "${GREEN}✅ Successfully pushed devbox-${blueprint}${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to build devbox-${blueprint}${NC}"
        exit 1
    fi
    
    cd ../..
    echo ""
done

echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✨ ALL BUILDS COMPLETE! ✨        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""

# Show summary
echo -e "${BLUE}📦 Built images:${NC}"
for blueprint in "${BLUEPRINTS[@]}"; do
    echo -e "  • ${DOCKER_USER}/devbox-${blueprint}:${VERSION}"
done

echo ""
if [ "$BUILD_MODE" == "push" ]; then
    echo -e "${GREEN}✅ All images are now available on Docker Hub!${NC}"
    echo -e "${BLUE}View at: https://hub.docker.com/u/${DOCKER_USER}${NC}"
else
    echo -e "${YELLOW}💡 To push images to Docker Hub, run:${NC}"
    echo -e "${YELLOW}   ./build-blueprints.sh push${NC}"
fi
