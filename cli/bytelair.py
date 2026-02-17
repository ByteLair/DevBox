#!/usr/bin/env python3
"""
ByteLair DevBox CLI - A friendly command-line interface for development workspaces
"""

import typer
import docker
import subprocess
import os
import json
import sys
from pathlib import Path
from typing import Optional
from rich.console import Console
from rich.table import Table
from rich import print as rprint
from project_detector import ProjectDetector
from config import Config

app = typer.Typer(
    name="bytelair",
    help="🚀 ByteLair DevBox - Your friendly development workspace manager",
    add_completion=False
)
console = Console()
config = Config()


def get_docker_client():
    """Get Docker client with error handling"""
    try:
        return docker.from_env()
    except docker.errors.DockerException as e:
        console.print(f"[red]❌ Docker não está rodando ou não está instalado[/red]")
        console.print(f"[yellow]Erro: {e}[/yellow]")
        raise typer.Exit(1)


def get_ssh_public_key():
    """Get user's SSH public key"""
    ssh_dir = Path.home() / ".ssh"
    
    # Priority order for SSH keys
    key_files = ["id_rsa.pub", "id_ed25519.pub", "id_ecdsa.pub"]
    
    for key_file in key_files:
        key_path = ssh_dir / key_file
        if key_path.exists():
            return key_path.read_text().strip()
    
    console.print("[yellow]⚠️  Nenhuma chave SSH encontrada. Gerando nova chave...[/yellow]")
    
    # Generate new SSH key
    subprocess.run(
        ["ssh-keygen", "-t", "ed25519", "-f", str(ssh_dir / "id_ed25519"), "-N", ""],
        check=True,
        capture_output=True
    )
    
    return (ssh_dir / "id_ed25519.pub").read_text().strip()


@app.command()
def up(
    name: Optional[str] = typer.Option(None, "--name", "-n", help="Nome do workspace"),
    port: int = typer.Option(2222, "--port", "-p", help="Porta SSH"),
    cpu: str = typer.Option("4", "--cpu", help="Limite de CPUs"),
    memory: str = typer.Option("8g", "--memory", "-m", help="Limite de memória"),
    template: Optional[str] = typer.Option(None, "--template", "-t", help="Template do workspace")
):
    """🚀 Sobe um workspace de desenvolvimento"""
    
    client = get_docker_client()
    
    # Auto-detect project if no name provided
    if not name:
        detector = ProjectDetector(Path.cwd())
        project_info = detector.detect()
        name = project_info.get("name", Path.cwd().name)
        
        if not template:
            template = project_info.get("type", "base")
        
        console.print(f"[cyan]🔍 Projeto detectado:[/cyan] {project_info['name']}")
        console.print(f"[cyan]📦 Tipo:[/cyan] {project_info['type']}")
    
    container_name = f"bytelair-{name}"
    volume_name = f"bytelair-{name}-storage"
    
    # Choose Docker image based on template
    image_map = {
        "base": "lyskdot/devbox:latest",
        "python": "lyskdot/devbox-python:latest",
        "node": "lyskdot/devbox:latest",  # Will be specialized later
        "fullstack": "lyskdot/devbox-fullstack:latest",
    }
    image = image_map.get(template or "base", "lyskdot/devbox:latest")
    
    # Check if container already exists
    try:
        existing = client.containers.get(container_name)
        if existing.status == "running":
            console.print(f"[yellow]⚠️  Workspace '{name}' já está rodando[/yellow]")
            return
        elif existing.status == "paused":
            console.print(f"[cyan]▶️  Resumindo workspace '{name}'...[/cyan]")
            existing.unpause()
            console.print(f"[green]✅ Workspace '{name}' resumido![/green]")
            return
        else:
            console.print(f"[cyan]▶️  Iniciando workspace existente '{name}'...[/cyan]")
            existing.start()
            console.print(f"[green]✅ Workspace '{name}' iniciado![/green]")
            return
    except docker.errors.NotFound:
        pass
    
    # Get SSH key
    ssh_key = get_ssh_public_key()
    
    console.print(f"[cyan]🐳 Criando workspace '{name}'...[/cyan]")
    console.print(f"[dim]Imagem: {image}[/dim]")
    console.print(f"[dim]Porta SSH: {port}[/dim]")
    console.print(f"[dim]Recursos: {cpu} CPUs, {memory} RAM[/dim]")
    
    try:
        # Pull image if not exists locally
        try:
            client.images.get(image)
        except docker.errors.ImageNotFound:
            console.print(f"[cyan]📥 Baixando imagem {image}...[/cyan]")
            client.images.pull(image)
        
        # Create volume
        try:
            client.volumes.get(volume_name)
        except docker.errors.NotFound:
            client.volumes.create(volume_name)
        
        # Run container
        container = client.containers.run(
            image,
            name=container_name,
            detach=True,
            ports={"22/tcp": port},
            environment={"SSH_PUBLIC_KEY": ssh_key},
            volumes={volume_name: {"bind": "/home/developer", "mode": "rw"}},
            cpu_quota=int(float(cpu) * 100000),
            mem_limit=memory,
            restart_policy={"Name": "unless-stopped"}
        )
        
        # Save workspace config
        workspace_config = {
            "name": name,
            "container_name": container_name,
            "port": port,
            "template": template or "base",
            "created_at": container.attrs["Created"]
        }
        config.save_workspace(name, workspace_config)
        
        console.print(f"\n[green]✅ Workspace '{name}' criado com sucesso![/green]")
        console.print(f"\n[cyan]📡 Conectar via SSH:[/cyan]")
        console.print(f"[bold]ssh -p {port} developer@localhost[/bold]")
        console.print(f"\n[cyan]💻 Conectar via VS Code:[/cyan]")
        console.print(f"[bold]bytelair connect {name}[/bold]")
        
    except docker.errors.APIError as e:
        console.print(f"[red]❌ Erro ao criar workspace: {e}[/red]")
        raise typer.Exit(1)


@app.command()
def down(
    name: Optional[str] = typer.Argument(None, help="Nome do workspace"),
    remove: bool = typer.Option(False, "--remove", "-r", help="Remove o container completamente")
):
    """⏹️  Para um workspace"""
    
    client = get_docker_client()
    
    if not name:
        # Get current directory name as default
        name = Path.cwd().name
    
    container_name = f"bytelair-{name}"
    
    try:
        container = client.containers.get(container_name)
        
        if remove:
            console.print(f"[yellow]🗑️  Removendo workspace '{name}'...[/yellow]")
            container.stop()
            container.remove()
            config.remove_workspace(name)
            console.print(f"[green]✅ Workspace '{name}' removido![/green]")
        else:
            console.print(f"[cyan]⏸️  Pausando workspace '{name}'...[/cyan]")
            container.pause()
            console.print(f"[green]✅ Workspace '{name}' pausado! (economizando recursos)[/green]")
            console.print(f"[dim]Use 'bytelair up {name}' para resumir[/dim]")
            
    except docker.errors.NotFound:
        console.print(f"[red]❌ Workspace '{name}' não encontrado[/red]")
        raise typer.Exit(1)


@app.command()
def connect(
    name: Optional[str] = typer.Argument(None, help="Nome do workspace"),
    ssh_only: bool = typer.Option(False, "--ssh", help="Conectar apenas via SSH")
):
    """💻 Conecta ao workspace via VS Code Remote SSH"""
    
    if not name:
        name = Path.cwd().name
    
    workspace = config.get_workspace(name)
    
    if not workspace:
        console.print(f"[red]❌ Workspace '{name}' não encontrado[/red]")
        console.print(f"[yellow]Use 'bytelair list' para ver workspaces disponíveis[/yellow]")
        raise typer.Exit(1)
    
    port = workspace["port"]
    
    if ssh_only:
        console.print(f"[cyan]🔌 Conectando via SSH...[/cyan]")
        subprocess.run(["ssh", "-p", str(port), "developer@localhost"])
    else:
        console.print(f"[cyan]💻 Abrindo VS Code Remote SSH...[/cyan]")
        ssh_config = f"ssh-remote+developer@localhost:{port}"
        subprocess.run(["code", "--remote", ssh_config, "/home/developer"])


@app.command()
def status(name: Optional[str] = typer.Argument(None, help="Nome do workspace")):
    """📊 Mostra status de um workspace"""
    
    client = get_docker_client()
    
    if not name:
        name = Path.cwd().name
    
    container_name = f"bytelair-{name}"
    
    try:
        container = client.containers.get(container_name)
        stats = container.stats(stream=False)
        
        # Calculate CPU usage
        cpu_delta = stats["cpu_stats"]["cpu_usage"]["total_usage"] - stats["precpu_stats"]["cpu_usage"]["total_usage"]
        system_delta = stats["cpu_stats"]["system_cpu_usage"] - stats["precpu_stats"]["system_cpu_usage"]
        cpu_percent = (cpu_delta / system_delta) * len(stats["cpu_stats"]["cpu_usage"]["percpu_usage"]) * 100
        
        # Calculate memory usage
        mem_usage = stats["memory_stats"]["usage"] / (1024 ** 3)  # GB
        mem_limit = stats["memory_stats"]["limit"] / (1024 ** 3)  # GB
        mem_percent = (stats["memory_stats"]["usage"] / stats["memory_stats"]["limit"]) * 100
        
        console.print(f"\n[bold cyan]📊 Status do Workspace: {name}[/bold cyan]\n")
        
        table = Table(show_header=False, box=None)
        table.add_column("Key", style="cyan")
        table.add_column("Value", style="white")
        
        status_color = "green" if container.status == "running" else "yellow"
        table.add_row("Status", f"[{status_color}]{container.status}[/{status_color}]")
        table.add_row("Container ID", container.short_id)
        table.add_row("CPU", f"{cpu_percent:.1f}%")
        table.add_row("Memória", f"{mem_usage:.2f}GB / {mem_limit:.2f}GB ({mem_percent:.1f}%)")
        table.add_row("Uptime", container.attrs["State"]["Status"])
        
        console.print(table)
        
    except docker.errors.NotFound:
        console.print(f"[red]❌ Workspace '{name}' não encontrado[/red]")
        raise typer.Exit(1)


@app.command()
def list():
    """📋 Lista todos os workspaces"""
    
    client = get_docker_client()
    
    containers = client.containers.list(all=True, filters={"name": "bytelair-"})
    
    if not containers:
        console.print("[yellow]📭 Nenhum workspace encontrado[/yellow]")
        console.print("[dim]Use 'bytelair up' para criar um workspace[/dim]")
        return
    
    console.print("\n[bold cyan]📦 Workspaces Disponíveis[/bold cyan]\n")
    
    table = Table(show_header=True)
    table.add_column("Nome", style="cyan")
    table.add_column("Status", style="white")
    table.add_column("Porta SSH", style="yellow")
    table.add_column("Template", style="magenta")
    table.add_column("Uptime", style="dim")
    
    for container in containers:
        name = container.name.replace("bytelair-", "")
        workspace = config.get_workspace(name) or {}
        
        status_emoji = {
            "running": "🟢",
            "paused": "🟡",
            "exited": "🔴",
        }.get(container.status, "⚪")
        
        port = workspace.get("port", "N/A")
        template = workspace.get("template", "base")
        
        # Get uptime from container
        uptime = container.attrs["State"].get("Status", "unknown")
        
        table.add_row(
            name,
            f"{status_emoji} {container.status}",
            str(port),
            template,
            uptime
        )
    
    console.print(table)
    console.print(f"\n[dim]💡 Use 'bytelair connect <nome>' para conectar a um workspace[/dim]")


@app.command()
def logs(
    name: Optional[str] = typer.Argument(None, help="Nome do workspace"),
    follow: bool = typer.Option(False, "--follow", "-f", help="Seguir logs em tempo real"),
    tail: int = typer.Option(100, "--tail", help="Número de linhas para mostrar")
):
    """📜 Mostra logs de um workspace"""
    
    client = get_docker_client()
    
    if not name:
        name = Path.cwd().name
    
    container_name = f"bytelair-{name}"
    
    try:
        container = client.containers.get(container_name)
        
        if follow:
            console.print(f"[cyan]📡 Seguindo logs de '{name}' (Ctrl+C para sair)...[/cyan]\n")
            for log in container.logs(stream=True, follow=True):
                console.print(log.decode("utf-8").rstrip())
        else:
            logs = container.logs(tail=tail).decode("utf-8")
            console.print(f"[cyan]📜 Últimas {tail} linhas de '{name}':[/cyan]\n")
            console.print(logs)
            
    except docker.errors.NotFound:
        console.print(f"[red]❌ Workspace '{name}' não encontrado[/red]")
        raise typer.Exit(1)
    except KeyboardInterrupt:
        console.print("\n[yellow]Logs interrompidos[/yellow]")


@app.command()
def template(action: str = typer.Argument(help="list ou use")):
    """📦 Gerencia templates de workspaces"""
    
    templates = {
        "base": {
            "name": "Base",
            "description": "Ubuntu 22.04 + Node.js 20 + Python 3.10 + Git",
            "image": "lyskdot/devbox:latest"
        },
        "python": {
            "name": "Python Data Science",
            "description": "Python + Jupyter + Pandas + NumPy + Scikit-learn",
            "image": "lyskdot/devbox-python:latest"
        },
        "node": {
            "name": "Node.js",
            "description": "Node.js 20 LTS + npm + yarn + pnpm",
            "image": "lyskdot/devbox:latest"
        },
        "fullstack": {
            "name": "Full Stack",
            "description": "Node.js + Python + PostgreSQL + Redis",
            "image": "lyskdot/devbox-fullstack:latest"
        }
    }
    
    if action == "list":
        console.print("\n[bold cyan]📦 Templates Disponíveis[/bold cyan]\n")
        
        table = Table(show_header=True)
        table.add_column("ID", style="cyan")
        table.add_column("Nome", style="white")
        table.add_column("Descrição", style="dim")
        
        for template_id, template_info in templates.items():
            table.add_row(
                template_id,
                template_info["name"],
                template_info["description"]
            )
        
        console.print(table)
        console.print(f"\n[dim]💡 Use 'bytelair up --template <id>' para criar workspace com template[/dim]")
    else:
        console.print(f"[red]❌ Ação '{action}' não reconhecida. Use 'list'[/red]")


@app.command()
def version():
    """ℹ️  Mostra versão do ByteLair CLI"""
    console.print("[bold cyan]ByteLair DevBox CLI[/bold cyan]")
    console.print("Version: [yellow]1.1.0[/yellow]")
    console.print("Docker Image: [yellow]lyskdot/devbox:latest[/yellow]")


def main():
    app()


if __name__ == "__main__":
    main()
