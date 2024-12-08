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
    rule = {"name": "@sdk"},
    repo = {
        "url": "https://github.com/work-spaces/sdk",
        "rev": "e0d25de7096ba69aa4f1f8cc307ff22f8ab13435",
        "checkout": "Revision",
        "clone": "Worktree"
    }
)