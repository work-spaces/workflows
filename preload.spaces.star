"""
Preload script for this workspace.

The spaces-starlark-sdk can be preloaded using: `--spaces-starlark-sdk`.

```
git clone https://github.com/work-spaces/workflows
spaces checkout --script=workflows/preload --script=workflows/conan-sdk --name=conan-quick-test
```

This file serves as an example of how to preload a custom spaces starlark SDK.

"""

checkout.add_repo(
    rule = {"name": "spaces-starlark-sdk"},
    repo = {
        "url": "https://github.com/work-spaces/spaces-starlark-sdk",
        "rev": "842e685de4e7a6aa4926369f7a5df6c179aae076",
        "checkout": "Revision",
        "clone": "Worktree"
    }
)