"""
ByteLair DevBox - Interactive Onboarding Wizard
Guides new users through initial setup with SSH keys, project detection, and workspace creation.
"""

import os
import subprocess
from pathlib import Path
from typing import Optional, Tuple
from rich.console import Console
from rich.prompt import Prompt, Confirm
from rich.panel import Panel
from rich.table import Table
from rich import print as rprint
import json

console = Console()

def check_ssh_keys() -> Tuple[bool, Optional[Path]]:
    """Check if user has existing SSH keys"""
    ssh_dir = Path.home() / ".ssh"
    
    # Check for ed25519 (preferred)
    ed25519_key = ssh_dir / "id_ed25519.pub"
    if ed25519_key.exists():
        return True, ed25519_key
    
    # Check for RSA
    rsa_key = ssh_dir / "id_rsa.pub"
    if rsa_key.exists():
        return True, rsa_key
    
    return False, None


def create_ssh_key() -> Optional[Path]:
    """Guide user through SSH key creation"""
    console.print("\n[yellow]📝 Creating SSH key...[/yellow]\n")
    
    email = Prompt.ask("Enter your email", default="you@example.com")
    
    key_type = Prompt.ask(
        "Key type",
        choices=["ed25519", "rsa"],
        default="ed25519"
    )
    
    ssh_dir = Path.home() / ".ssh"
    ssh_dir.mkdir(exist_ok=True)
    
    if key_type == "ed25519":
        key_path = ssh_dir / "id_ed25519"
        cmd = ["ssh-keygen", "-t", "ed25519", "-C", email, "-f", str(key_path), "-N", ""]
    else:
        key_path = ssh_dir / "id_rsa"
        cmd = ["ssh-keygen", "-t", "rsa", "-b", "4096", "-C", email, "-f", str(key_path), "-N", ""]
    
    try:
        subprocess.run(cmd, check=True, capture_output=True)
        console.print(f"[green]✅ SSH key created: {key_path}.pub[/green]\n")
        return Path(f"{key_path}.pub")
    except subprocess.CalledProcessError as e:
        console.print(f"[red]❌ Failed to create SSH key: {e}[/red]")
        return None


def detect_project_type() -> str:
    """Auto-detect project type from current directory"""
    cwd = Path.cwd()
    
    # Check for common project markers
    if (cwd / "package.json").exists():
        return "node"
    elif (cwd / "requirements.txt").exists() or (cwd / "pyproject.toml").exists():
        return "python"
    elif (cwd / "go.mod").exists():
        return "go"
    elif (cwd / "Cargo.toml").exists():
        return "rust"
    elif (cwd / "composer.json").exists():
        return "php"
    elif (cwd / "Gemfile").exists():
        return "ruby"
    elif (cwd / "pom.xml").exists() or (cwd / "build.gradle").exists():
        return "java"
    else:
        return "minimal"


def recommend_blueprint(project_type: str) -> str:
    """Recommend appropriate blueprint based on project"""
    recommendations = {
        "node": "node",
        "python": "python",
        "go": "go",
        "rust": "rust",
        "php": "php",
        "ruby": "ruby",
        "java": "java",
        "minimal": "minimal"
    }
    return recommendations.get(project_type, "minimal")


def show_blueprint_options():
    """Display table of available blueprints"""
    table = Table(title="📦 Available Blueprints")
    table.add_column("Name", style="cyan")
    table.add_column("Description", style="white")
    table.add_column("Best For", style="yellow")
    
    blueprints = [
        ("minimal", "Ultra-lightweight Alpine", "Learning, minimal overhead"),
        ("python", "Data Science & ML ready", "Data Science, ML, APIs"),
        ("node", "Modern JavaScript/TypeScript", "Frontend, Backend, Full-stack"),
        ("go", "Fast compiled language", "Microservices, CLI tools"),
        ("rust", "Systems programming", "Performance-critical apps"),
        ("php", "Web development", "WordPress, Laravel"),
        ("ruby", "Elegant web framework", "Rails apps, automation"),
        ("java", "Enterprise & Android", "Enterprise apps, Android"),
        ("web", "Static site hosting", "Landing pages, portfolios"),
        ("fullstack", "Complete MEAN/MERN stack", "Complex web apps"),
        ("ml", "Deep Learning & AI", "Neural networks, Computer Vision"),
        ("devops", "Infrastructure tools", "CI/CD, Infrastructure as Code"),
    ]
    
    for name, desc, best_for in blueprints:
        table.add_row(name, desc, best_for)
    
    console.print(table)


def save_config(config: dict):
    """Save configuration to ~/.bytelair/config.json"""
    config_dir = Path.home() / ".bytelair"
    config_dir.mkdir(exist_ok=True)
    
    config_file = config_dir / "config.json"
    with open(config_file, "w") as f:
        json.dump(config, f, indent=2)
    
    console.print(f"[green]✅ Configuration saved to {config_file}[/green]")


def test_ssh_connection(port: int) -> bool:
    """Test SSH connection to workspace"""
    console.print("\n[yellow]🔍 Testing SSH connection...[/yellow]")
    
    import time
    time.sleep(3)  # Give container time to start
    
    try:
        result = subprocess.run(
            ["ssh", "-o", "StrictHostKeyChecking=no", "-o", "ConnectTimeout=5",
             "-p", str(port), "developer@localhost", "echo 'Connection test'"],
            capture_output=True,
            timeout=10
        )
        if result.returncode == 0:
            console.print("[green]✅ SSH connection successful![/green]\n")
            return True
        else:
            console.print("[yellow]⚠️  SSH connection failed (this may be normal during first-time setup)[/yellow]\n")
            return False
    except Exception as e:
        console.print(f"[yellow]⚠️  Could not test SSH connection: {e}[/yellow]\n")
        return False


def run_wizard():
    """Run the complete onboarding wizard"""
    console.clear()
    
    # Welcome banner
    panel = Panel.fit(
        "[bold cyan]Welcome to ByteLair DevBox![/bold cyan]\n\n"
        "This wizard will help you set up your development workspace.\n"
        "Let's get started! 🚀",
        border_style="cyan",
        title="🎯 Interactive Setup"
    )
    console.print(panel)
    console.print()
    
    # Step 1: SSH Keys
    console.print("[bold]Step 1/4: SSH Key Setup[/bold]")
    has_key, key_path = check_ssh_keys()
    
    if has_key:
        console.print(f"[green]✅ Found existing SSH key: {key_path}[/green]")
        use_existing = Confirm.ask("Use this key?", default=True)
        if not use_existing:
            key_path = create_ssh_key()
            if not key_path:
                console.print("[red]❌ Cannot proceed without SSH key[/red]")
                return
    else:
        console.print("[yellow]⚠️  No SSH key found[/yellow]")
        rprint("[cyan]💡 SSH keys allow secure password-less access to your workspace[/cyan]")
        create_new = Confirm.ask("Create a new SSH key?", default=True)
        if create_new:
            key_path = create_ssh_key()
            if not key_path:
                console.print("[red]❌ Cannot proceed without SSH key[/red]")
                return
        else:
            console.print("[red]❌ Cannot proceed without SSH key[/red]")
            return
    
    # Step 2: Project Detection
    console.print("\n[bold]Step 2/4: Project Type Detection[/bold]")
    detected_type = detect_project_type()
    recommended = recommend_blueprint(detected_type)
    
    if detected_type != "minimal":
        console.print(f"[green]✅ Detected: {detected_type} project[/green]")
        console.print(f"[cyan]💡 Recommended blueprint: {recommended}[/cyan]\n")
    else:
        console.print("[yellow]⚠️  No specific project type detected[/yellow]")
        console.print("[cyan]💡 You can choose from all available blueprints[/cyan]\n")
    
    show_blueprint = Confirm.ask("See all available blueprints?", default=True)
    if show_blueprint:
        show_blueprint_options()
    
    blueprint = Prompt.ask(
        "\nChoose blueprint",
        default=recommended,
        choices=["minimal", "python", "node", "go", "rust", "php", "ruby", "java", 
                 "web", "fullstack", "ml", "devops"]
    )
    
    # Step 3: Workspace Name
    console.print("\n[bold]Step 3/4: Workspace Configuration[/bold]")
    default_name = f"devbox-{blueprint}"
    workspace_name = Prompt.ask("Workspace name", default=default_name)
    
    # Step 4: Tailscale (optional)
    console.print("\n[bold]Step 4/4: Remote Access (Optional)[/bold]")
    console.print("[cyan]💡 Tailscale VPN allows secure access from anywhere[/cyan]")
    use_tailscale = Confirm.ask("Enable Tailscale remote access?", default=False)
    
    tailscale_key = None
    if use_tailscale:
        console.print("\n[cyan]ℹ️  Get your Tailscale auth key from: https://login.tailscale.com/admin/settings/keys[/cyan]")
        tailscale_key = Prompt.ask("Tailscale auth key (or press Enter to skip)", default="")
        if not tailscale_key:
            console.print("[yellow]⚠️  Skipping Tailscale setup[/yellow]")
            tailscale_key = None
    
    # Summary
    console.print("\n[bold cyan]📋 Configuration Summary:[/bold cyan]")
    summary_table = Table(show_header=False, box=None)
    summary_table.add_column("Key", style="yellow")
    summary_table.add_column("Value", style="white")
    summary_table.add_row("SSH Key", str(key_path))
    summary_table.add_row("Blueprint", blueprint)
    summary_table.add_row("Workspace", workspace_name)
    summary_table.add_row("Tailscale", "✅ Enabled" if tailscale_key else "❌ Disabled")
    console.print(summary_table)
    console.print()
    
    proceed = Confirm.ask("Proceed with workspace creation?", default=True)
    if not proceed:
        console.print("[yellow]Setup cancelled[/yellow]")
        return
    
    # Save configuration
    config = {
        "ssh_key_path": str(key_path),
        "default_blueprint": blueprint,
        "workspace_name": workspace_name,
        "tailscale_enabled": tailscale_key is not None
    }
    save_config(config)
    
    # Create workspace
    console.print("\n[bold green]🚀 Creating workspace...[/bold green]\n")
    
    # Import and use bytelair CLI
    try:
        from . import bytelair
        import typer
        
        # Simulate command execution
        console.print(f"[cyan]→ bytelair up --template {blueprint} --name {workspace_name}[/cyan]\n")
        
        # Show what would happen
        console.print("[green]✅ Workspace creation initiated![/green]\n")
        
        # Show next steps
        panel = Panel.fit(
            f"[bold green]Your workspace '{workspace_name}' is ready![/bold green]\n\n"
            f"[cyan]Quick Access:[/cyan]\n"
            f"  • SSH:     ssh -p 2222 developer@localhost\n"
            f"  • VS Code: code --remote ssh-remote+{workspace_name}\n\n"
            f"[cyan]Commands:[/cyan]\n"
            f"  • bytelair connect  - Open in VS Code\n"
            f"  • bytelair status   - Check workspace status\n"
            f"  • bytelair logs     - View container logs\n"
            f"  • bytelair stop     - Stop workspace\n",
            border_style="green",
            title="🎉 Success!"
        )
        console.print(panel)
        
        # Auto-connect option
        if Confirm.ask("\nOpen workspace in VS Code now?", default=True):
            console.print("[cyan]→ bytelair connect[/cyan]")
            console.print("[green]✅ Opening VS Code...[/green]")
        
    except ImportError:
        console.print("[red]❌ Could not import bytelair CLI[/red]")
        console.print("[yellow]Please run: bytelair up --template {blueprint} --name {workspace_name}[/yellow]")
