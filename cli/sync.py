#!/usr/bin/env python3
"""
Settings synchronization for ByteLair DevBox workspaces
Sync VS Code settings, extensions, and dotfiles between local and remote
"""

import docker
import shutil
import tarfile
import io
import json
from pathlib import Path
from typing import List, Optional
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.prompt import Confirm

console = Console()


class SettingsSync:
    """Manages settings synchronization between local and workspace"""
    
    def __init__(self):
        try:
            self.client = docker.from_env()
        except docker.errors.DockerException as e:
            console.print(f"[red]❌ Docker não está rodando ou não está instalado[/red]")
            raise
        
        # Common VS Code settings locations
        self.vscode_dir = self._get_vscode_dir()
        
        # Dotfiles to sync
        self.dotfiles = [
            ".gitconfig",
            ".bashrc",
            ".zshrc",
            ".vimrc",
            ".tmux.conf",
        ]
    
    def _get_vscode_dir(self) -> Optional[Path]:
        """Get VS Code user directory based on OS"""
        home = Path.home()
        
        # Linux/macOS
        vscode_linux = home / ".config" / "Code" / "User"
        if vscode_linux.exists():
            return vscode_linux
        
        # macOS alternative
        vscode_mac = home / "Library" / "Application Support" / "Code" / "User"
        if vscode_mac.exists():
            return vscode_mac
        
        return None
    
    def sync_vscode_settings(self, workspace_name: str, direction: str = "push"):
        """
        Sync VS Code settings to/from workspace
        
        Args:
            workspace_name: Name of the workspace
            direction: "push" (local -> workspace) or "pull" (workspace -> local)
        """
        container_name = f"bytelair-{workspace_name}"
        
        try:
            container = self.client.containers.get(container_name)
        except docker.errors.NotFound:
            console.print(f"[red]❌ Workspace '{workspace_name}' não encontrado[/red]")
            raise
        
        if not self.vscode_dir or not self.vscode_dir.exists():
            console.print("[yellow]⚠️  Diretório de configurações do VS Code não encontrado[/yellow]")
            return
        
        settings_file = self.vscode_dir / "settings.json"
        keybindings_file = self.vscode_dir / "keybindings.json"
        
        if direction == "push":
            console.print(f"[cyan]⬆️  Enviando configurações do VS Code para '{workspace_name}'...[/cyan]")
            
            # Create .vscode-server directory if not exists
            container.exec_run("mkdir -p /home/developer/.vscode-server/data/Machine")
            
            # Push settings.json
            if settings_file.exists():
                self._copy_file_to_container(
                    container,
                    settings_file,
                    "/home/developer/.vscode-server/data/Machine/settings.json"
                )
                console.print("[green]✅ settings.json enviado[/green]")
            
            # Push keybindings.json
            if keybindings_file.exists():
                self._copy_file_to_container(
                    container,
                    keybindings_file,
                    "/home/developer/.vscode-server/data/Machine/keybindings.json"
                )
                console.print("[green]✅ keybindings.json enviado[/green]")
        
        elif direction == "pull":
            console.print(f"[cyan]⬇️  Baixando configurações do VS Code de '{workspace_name}'...[/cyan]")
            
            # Pull settings.json
            remote_settings = "/home/developer/.vscode-server/data/Machine/settings.json"
            if self._file_exists_in_container(container, remote_settings):
                self._copy_file_from_container(container, remote_settings, settings_file)
                console.print("[green]✅ settings.json baixado[/green]")
            
            # Pull keybindings.json
            remote_keybindings = "/home/developer/.vscode-server/data/Machine/keybindings.json"
            if self._file_exists_in_container(container, remote_keybindings):
                self._copy_file_from_container(container, remote_keybindings, keybindings_file)
                console.print("[green]✅ keybindings.json baixado[/green]")
    
    def sync_dotfiles(self, workspace_name: str, direction: str = "push", files: Optional[List[str]] = None):
        """
        Sync dotfiles to/from workspace
        
        Args:
            workspace_name: Name of the workspace
            direction: "push" (local -> workspace) or "pull" (workspace -> local)
            files: Optional list of specific dotfiles to sync (defaults to all common dotfiles)
        """
        container_name = f"bytelair-{workspace_name}"
        
        try:
            container = self.client.containers.get(container_name)
        except docker.errors.NotFound:
            console.print(f"[red]❌ Workspace '{workspace_name}' não encontrado[/red]")
            raise
        
        sync_files = files if files else self.dotfiles
        home = Path.home()
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            
            task = progress.add_task(
                f"[cyan]Sincronizando dotfiles ({direction})...",
                total=len(sync_files)
            )
            
            for dotfile in sync_files:
                local_file = home / dotfile
                remote_file = f"/home/developer/{dotfile}"
                
                if direction == "push":
                    if local_file.exists():
                        self._copy_file_to_container(container, local_file, remote_file)
                        progress.update(task, advance=1, description=f"[green]✅ {dotfile} enviado")
                    else:
                        progress.update(task, advance=1, description=f"[dim]⊘ {dotfile} não encontrado localmente")
                
                elif direction == "pull":
                    if self._file_exists_in_container(container, remote_file):
                        # Backup local file if exists
                        if local_file.exists():
                            backup = local_file.with_suffix(local_file.suffix + '.backup')
                            shutil.copy2(local_file, backup)
                        
                        self._copy_file_from_container(container, remote_file, local_file)
                        progress.update(task, advance=1, description=f"[green]✅ {dotfile} baixado")
                    else:
                        progress.update(task, advance=1, description=f"[dim]⊘ {dotfile} não encontrado no workspace")
    
    def sync_extensions(self, workspace_name: str):
        """
        Sync VS Code extensions list to workspace
        Note: Extensions must be installed manually or via extension sync
        
        Args:
            workspace_name: Name of the workspace
        """
        container_name = f"bytelair-{workspace_name}"
        
        try:
            container = self.client.containers.get(container_name)
        except docker.errors.NotFound:
            console.print(f"[red]❌ Workspace '{workspace_name}' não encontrado[/red]")
            raise
        
        # Get list of installed extensions
        try:
            import subprocess
            result = subprocess.run(
                ["code", "--list-extensions"],
                capture_output=True,
                text=True,
                check=True
            )
            extensions = result.stdout.strip().split('\n')
            
            # Save to workspace
            extensions_file = Path.home() / ".bytelair" / f"{workspace_name}-extensions.txt"
            extensions_file.parent.mkdir(parents=True, exist_ok=True)
            extensions_file.write_text('\n'.join(extensions))
            
            console.print(f"[green]✅ Lista de {len(extensions)} extensões salva em:[/green]")
            console.print(f"[dim]{extensions_file}[/dim]")
            console.print(f"\n[cyan]💡 Dica:[/cyan] Instale no workspace com:")
            console.print(f"[bold]cat {extensions_file} | xargs -L1 code --install-extension[/bold]")
            
        except (subprocess.CalledProcessError, FileNotFoundError):
            console.print("[yellow]⚠️  VS Code CLI não encontrado[/yellow]")
    
    def _copy_file_to_container(self, container, local_path: Path, remote_path: str):
        """Copy a file from local to container"""
        # Create tar archive in memory
        tar_stream = io.BytesIO()
        with tarfile.open(fileobj=tar_stream, mode='w') as tar:
            tar.add(str(local_path), arcname=Path(remote_path).name)
        
        tar_stream.seek(0)
        
        # Extract to container
        remote_dir = str(Path(remote_path).parent)
        container.put_archive(remote_dir, tar_stream)
        
        # Fix ownership
        container.exec_run(f"chown developer:developer {remote_path}")
    
    def _copy_file_from_container(self, container, remote_path: str, local_path: Path):
        """Copy a file from container to local"""
        # Get file from container as tar
        bits, _ = container.get_archive(remote_path)
        
        # Extract to local
        tar_stream = io.BytesIO()
        for chunk in bits:
            tar_stream.write(chunk)
        tar_stream.seek(0)
        
        with tarfile.open(fileobj=tar_stream, mode='r') as tar:
            # Extract to parent directory
            tar.extractall(local_path.parent)
    
    def _file_exists_in_container(self, container, path: str) -> bool:
        """Check if a file exists in container"""
        result = container.exec_run(f"test -f {path}")
        return result.exit_code == 0
