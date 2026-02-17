"""
Project type detection based on files in the directory
"""

from pathlib import Path
from typing import Dict


class ProjectDetector:
    """Detects project type based on configuration files"""
    
    def __init__(self, project_path: Path):
        self.project_path = project_path
    
    def detect(self) -> Dict[str, str]:
        """
        Detect project type and return metadata
        
        Returns:
            dict: Project information with keys: name, type, description
        """
        project_name = self.project_path.name
        project_type = "base"
        description = "Generic development workspace"
        
        # Python projects
        if (self.project_path / "requirements.txt").exists():
            project_type = "python"
            description = "Python project"
            
            # Check for data science libraries
            if self._has_data_science_deps():
                description = "Python Data Science project"
        
        elif (self.project_path / "pyproject.toml").exists():
            project_type = "python"
            description = "Python project (Poetry/PDM)"
        
        elif (self.project_path / "setup.py").exists():
            project_type = "python"
            description = "Python package"
        
        elif (self.project_path / "Pipfile").exists():
            project_type = "python"
            description = "Python project (Pipenv)"
        
        # Node.js projects
        elif (self.project_path / "package.json").exists():
            project_type = "node"
            description = "Node.js project"
            
            # Check for specific frameworks
            if self._is_react_project():
                description = "React project"
            elif self._is_vue_project():
                description = "Vue.js project"
            elif self._is_next_project():
                description = "Next.js project"
            elif self._is_express_project():
                description = "Express.js project"
        
        # Full stack indicators
        if self._is_fullstack_project():
            project_type = "fullstack"
            description = "Full Stack project"
        
        # Ruby projects
        elif (self.project_path / "Gemfile").exists():
            project_type = "ruby"
            description = "Ruby project"
            
            if (self.project_path / "config/routes.rb").exists():
                description = "Ruby on Rails project"
        
        # Go projects
        elif (self.project_path / "go.mod").exists():
            project_type = "go"
            description = "Go project"
        
        # Rust projects
        elif (self.project_path / "Cargo.toml").exists():
            project_type = "rust"
            description = "Rust project"
        
        # Java/Kotlin projects
        elif (self.project_path / "pom.xml").exists():
            project_type = "java"
            description = "Maven project"
        
        elif (self.project_path / "build.gradle").exists() or (self.project_path / "build.gradle.kts").exists():
            project_type = "java"
            description = "Gradle project"
        
        # PHP projects
        elif (self.project_path / "composer.json").exists():
            project_type = "php"
            description = "PHP project"
            
            if (self.project_path / "artisan").exists():
                description = "Laravel project"
        
        return {
            "name": project_name,
            "type": project_type,
            "description": description
        }
    
    def _has_data_science_deps(self) -> bool:
        """Check if requirements.txt has data science libraries"""
        req_file = self.project_path / "requirements.txt"
        if not req_file.exists():
            return False
        
        content = req_file.read_text().lower()
        data_libs = ["pandas", "numpy", "scipy", "scikit-learn", "jupyter", "matplotlib", "seaborn"]
        
        return any(lib in content for lib in data_libs)
    
    def _is_react_project(self) -> bool:
        """Check if it's a React project"""
        package_json = self.project_path / "package.json"
        if not package_json.exists():
            return False
        
        import json
        try:
            data = json.loads(package_json.read_text())
            deps = {**data.get("dependencies", {}), **data.get("devDependencies", {})}
            return "react" in deps
        except:
            return False
    
    def _is_vue_project(self) -> bool:
        """Check if it's a Vue project"""
        package_json = self.project_path / "package.json"
        if not package_json.exists():
            return False
        
        import json
        try:
            data = json.loads(package_json.read_text())
            deps = {**data.get("dependencies", {}), **data.get("devDependencies", {})}
            return "vue" in deps
        except:
            return False
    
    def _is_next_project(self) -> bool:
        """Check if it's a Next.js project"""
        package_json = self.project_path / "package.json"
        if not package_json.exists():
            return False
        
        import json
        try:
            data = json.loads(package_json.read_text())
            deps = {**data.get("dependencies", {}), **data.get("devDependencies", {})}
            return "next" in deps
        except:
            return False
    
    def _is_express_project(self) -> bool:
        """Check if it's an Express project"""
        package_json = self.project_path / "package.json"
        if not package_json.exists():
            return False
        
        import json
        try:
            data = json.loads(package_json.read_text())
            deps = {**data.get("dependencies", {}), **data.get("devDependencies", {})}
            return "express" in deps
        except:
            return False
    
    def _is_fullstack_project(self) -> bool:
        """Check if it's a full stack project (has both frontend and backend)"""
        has_backend = (
            (self.project_path / "requirements.txt").exists() or
            (self.project_path / "package.json").exists()
        )
        
        has_frontend = (
            (self.project_path / "package.json").exists() and
            (self.project_path / "public").exists()
        )
        
        has_database = (
            (self.project_path / "docker-compose.yml").exists() or
            (self.project_path / "prisma").exists() or
            (self.project_path / "migrations").exists()
        )
        
        return has_backend and (has_frontend or has_database)
