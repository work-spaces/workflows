"""
Preload script for this workspace.
"""

checkout.add_repo(
    rule = {"name": "spaces-starlark-sdk"},
    repo = {
        "url": "https://github.com/work-spaces/spaces-starlark-sdk",
        "rev": "main",
        "checkout": "Revision",
        "clone": "Worktree"
    }
)