"""
Preload script for this workspace.
"""

checkout.add_repo(
    rule = {"name": "sysroot-packages"},
    repo = {
        "url": "https://github.com/work-spaces/sysroot",
        "rev": "main",
        "checkout": "Revision",
        "clone": "Worktree"
    }
)