#!/usr/bin/env python3
"""
Snapshot management for ByteLair DevBox workspaces
Allows creating, restoring, and managing workspace snapshots
"""

import docker
import json
from pathlib import Path
from datetime import datetime
from typing import Optional, Dict, List
from rich.console import Console
from rich.table import Table
from rich.prompt import Confirm
from config import Config

console = Console()
config = Config()


class SnapshotManager:
    """Manages workspace snapshots using Docker commit"""
    
    def __init__(self):
        try:
            self.client = docker.from_env()
        except docker.errors.DockerException as e:
            console.print(f"[red]❌ Docker não está rodando ou não está instalado[/red]")
            raise
        
        # Snapshots directory
        self.snapshots_dir = Path.home() / ".bytelair" / "snapshots"
        self.snapshots_dir.mkdir(parents=True, exist_ok=True)
        
        # Metadata file
        self.metadata_file = self.snapshots_dir / "metadata.json"
        self._load_metadata()
    
    def _load_metadata(self):
        """Load snapshots metadata from disk"""
        if self.metadata_file.exists():
            with open(self.metadata_file) as f:
                self.metadata = json.load(f)
        else:
            self.metadata = {}
    
    def _save_metadata(self):
        """Save snapshots metadata to disk"""
        with open(self.metadata_file, 'w') as f:
            json.dump(self.metadata, f, indent=2)
    
    def create_snapshot(self, workspace_name: str, snapshot_name: Optional[str] = None, message: str = "") -> str:
        """
        Create a snapshot of a workspace
        
        Args:
            workspace_name: Name of the workspace to snapshot
            snapshot_name: Optional custom snapshot name (default: timestamp)
            message: Optional description message
        
        Returns:
            Name of the created snapshot
        """
        # Get workspace container
        container_name = f"bytelair-{workspace_name}"
        
        try:
            container = self.client.containers.get(container_name)
        except docker.errors.NotFound:
            console.print(f"[red]❌ Workspace '{workspace_name}' não encontrado[/red]")
            raise
        
        # Generate snapshot name if not provided
        if not snapshot_name:
            timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
            snapshot_name = f"{workspace_name}-{timestamp}"
        
        # Full image tag
        snapshot_tag = f"bytelair-snapshot:{snapshot_name}"
        
        console.print(f"[cyan]📸 Criando snapshot '{snapshot_name}'...[/cyan]")
        
        # Commit container to image
        try:
            image = container.commit(
                repository="bytelair-snapshot",
                tag=snapshot_name,
                message=message,
                author="ByteLair CLI"
            )
            
            # Store metadata
            metadata = {
                "workspace": workspace_name,
                "created_at": datetime.now().isoformat(),
                "message": message,
                "image_id": image.id,
                "image_tag": snapshot_tag,
                "container_state": container.status
            }
            
            self.metadata[snapshot_name] = metadata
            self._save_metadata()
            
            # Get image size
            size_mb = image.attrs.get('Size', 0) / (1024 * 1024)
            
            console.print(f"[green]✅ Snapshot '{snapshot_name}' criado com sucesso![/green]")
            console.print(f"[dim]Tamanho: {size_mb:.1f} MB[/dim]")
            console.print(f"[dim]Image ID: {image.short_id}[/dim]")
            
            return snapshot_name
            
        except docker.errors.APIError as e:
            console.print(f"[red]❌ Erro ao criar snapshot: {e}[/red]")
            raise
    
    def list_snapshots(self, workspace_name: Optional[str] = None) -> List[Dict]:
        """
        List all snapshots, optionally filtered by workspace
        
        Args:
            workspace_name: Optional workspace name to filter by
        
        Returns:
            List of snapshot metadata dictionaries
        """
        snapshots = []
        
        for name, meta in self.metadata.items():
            if workspace_name and meta.get('workspace') != workspace_name:
                continue
            
            # Check if image still exists
            try:
                image = self.client.images.get(meta['image_tag'])
                meta['exists'] = True
                meta['size_mb'] = image.attrs.get('Size', 0) / (1024 * 1024)
            except docker.errors.ImageNotFound:
                meta['exists'] = False
                meta['size_mb'] = 0
            
            snapshots.append({
                'name': name,
                **meta
            })
        
        # Sort by creation time, newest first
        snapshots.sort(key=lambda x: x.get('created_at', ''), reverse=True)
        
        return snapshots
    
    def restore_snapshot(self, snapshot_name: str, new_workspace_name: Optional[str] = None, port: int = 2222):
        """
        Restore a workspace from a snapshot
        
        Args:
            snapshot_name: Name of the snapshot to restore
            new_workspace_name: Optional new name for restored workspace
            port: SSH port for the restored workspace
        """
        if snapshot_name not in self.metadata:
            console.print(f"[red]❌ Snapshot '{snapshot_name}' não encontrado[/red]")
            raise ValueError(f"Snapshot not found: {snapshot_name}")
        
        meta = self.metadata[snapshot_name]
        image_tag = meta['image_tag']
        
        # Check if image exists
        try:
            image = self.client.images.get(image_tag)
        except docker.errors.ImageNotFound:
            console.print(f"[red]❌ Imagem do snapshot não encontrada: {image_tag}[/red]")
            console.print(f"[yellow]O snapshot pode ter sido removido manualmente[/yellow]")
            raise
        
        # Determine workspace name
        if not new_workspace_name:
            new_workspace_name = f"{meta['workspace']}-restored"
        
        container_name = f"bytelair-{new_workspace_name}"
        volume_name = f"bytelair-{new_workspace_name}-storage"
        
        console.print(f"[cyan]♻️  Restaurando snapshot '{snapshot_name}' como '{new_workspace_name}'...[/cyan]")
        
        try:
            # Create volume
            try:
                self.client.volumes.get(volume_name)
            except docker.errors.NotFound:
                self.client.volumes.create(volume_name)
            
            # Run container from snapshot
            container = self.client.containers.run(
                image_tag,
                name=container_name,
                detach=True,
                ports={"22/tcp": port},
                volumes={volume_name: {"bind": "/home/developer", "mode": "rw"}},
                restart_policy={"Name": "unless-stopped"}
            )
            
            # Save workspace config
            workspace_config = {
                "name": new_workspace_name,
                "container_name": container_name,
                "port": port,
                "template": "snapshot",
                "snapshot_source": snapshot_name,
                "created_at": container.attrs["Created"]
            }
            config.save_workspace(new_workspace_name, workspace_config)
            
            console.print(f"[green]✅ Workspace '{new_workspace_name}' restaurado com sucesso![/green]")
            console.print(f"\n[cyan]📡 Conectar via SSH:[/cyan]")
            console.print(f"[bold]ssh -p {port} developer@localhost[/bold]")
            
        except docker.errors.APIError as e:
            console.print(f"[red]❌ Erro ao restaurar snapshot: {e}[/red]")
            raise
    
    def delete_snapshot(self, snapshot_name: str, force: bool = False):
        """
        Delete a snapshot
        
        Args:
            snapshot_name: Name of the snapshot to delete
            force: Force deletion without confirmation
        """
        if snapshot_name not in self.metadata:
            console.print(f"[red]❌ Snapshot '{snapshot_name}' não encontrado[/red]")
            raise ValueError(f"Snapshot not found: {snapshot_name}")
        
        meta = self.metadata[snapshot_name]
        image_tag = meta['image_tag']
        
        # Confirm deletion
        if not force:
            if not Confirm.ask(f"[yellow]Deseja realmente deletar o snapshot '{snapshot_name}'?[/yellow]"):
                console.print("[dim]Operação cancelada[/dim]")
                return
        
        # Remove Docker image
        try:
            self.client.images.remove(image_tag, force=True)
            console.print(f"[green]✅ Imagem do snapshot removida[/green]")
        except docker.errors.ImageNotFound:
            console.print(f"[yellow]⚠️  Imagem já foi removida anteriormente[/yellow]")
        except docker.errors.APIError as e:
            console.print(f"[yellow]⚠️  Erro ao remover imagem: {e}[/yellow]")
        
        # Remove metadata
        del self.metadata[snapshot_name]
        self._save_metadata()
        
        console.print(f"[green]✅ Snapshot '{snapshot_name}' deletado[/green]")
    
    def show_snapshots_table(self, snapshots: List[Dict]):
        """Display snapshots in a formatted table"""
        if not snapshots:
            console.print("[yellow]Nenhum snapshot encontrado[/yellow]")
            return
        
        table = Table(title="📸 ByteLair Snapshots", show_header=True, header_style="bold cyan")
        table.add_column("Nome", style="cyan")
        table.add_column("Workspace", style="yellow")
        table.add_column("Criado em", style="dim")
        table.add_column("Tamanho", justify="right")
        table.add_column("Status", justify="center")
        table.add_column("Mensagem", style="dim")
        
        for snap in snapshots:
            created = datetime.fromisoformat(snap['created_at']).strftime("%Y-%m-%d %H:%M")
            size = f"{snap.get('size_mb', 0):.1f} MB"
            status = "✅" if snap.get('exists', False) else "❌"
            message = snap.get('message', '')[:40]  # Truncate long messages
            
            table.add_row(
                snap['name'],
                snap['workspace'],
                created,
                size,
                status,
                message
            )
        
        console.print(table)
