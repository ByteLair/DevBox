"""
Configuration management for ByteLair workspaces
"""

import json
from pathlib import Path
from typing import Dict, Optional


class Config:
    """Manages ByteLair workspace configurations"""
    
    def __init__(self):
        self.config_dir = Path.home() / ".bytelair"
        self.config_file = self.config_dir / "workspaces.json"
        self._ensure_config_dir()
    
    def _ensure_config_dir(self):
        """Create config directory if it doesn't exist"""
        self.config_dir.mkdir(parents=True, exist_ok=True)
        if not self.config_file.exists():
            self._save_config({})
    
    def _load_config(self) -> Dict:
        """Load configuration from file"""
        try:
            return json.loads(self.config_file.read_text())
        except (json.JSONDecodeError, FileNotFoundError):
            return {}
    
    def _save_config(self, config: Dict):
        """Save configuration to file"""
        self.config_file.write_text(json.dumps(config, indent=2))
    
    def save_workspace(self, name: str, workspace_config: Dict):
        """Save workspace configuration"""
        config = self._load_config()
        config[name] = workspace_config
        self._save_config(config)
    
    def get_workspace(self, name: str) -> Optional[Dict]:
        """Get workspace configuration by name"""
        config = self._load_config()
        return config.get(name)
    
    def list_workspaces(self) -> Dict:
        """List all workspaces"""
        return self._load_config()
    
    def remove_workspace(self, name: str):
        """Remove workspace configuration"""
        config = self._load_config()
        if name in config:
            del config[name]
            self._save_config(config)
    
    def update_workspace(self, name: str, updates: Dict):
        """Update workspace configuration"""
        config = self._load_config()
        if name in config:
            config[name].update(updates)
            self._save_config(config)
