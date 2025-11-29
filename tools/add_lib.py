from typing import List
from langchain_core.tools import tool
import subprocess

@tool
def add_dependencies(dependencies: List[str]) -> str:
    """
    Install given Python packages using pip.
    """

    try:
        result = subprocess.run(
            ["pip", "install"] + dependencies,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        if result.returncode == 0:
            return "Successfully installed: " + ", ".join(dependencies)
        else:
            return (
                "Pip installation failed.\n"
                f"Exit code: {result.returncode}\n"
                f"Error: {result.stderr}"
            )

    except Exception as e:
        return f"Unexpected error: {e}"
