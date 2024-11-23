"""
Preload script for this workspace.

The spaces-starlark-sdk can be preloaded using: `--spaces-starlark-sdk`.

```
git clone https://github.com/work-spaces/workflows

spaces checkout --spaces-starlark-sdk --script=workflows/conan-sdk --name=conan-quick-test
# is equivalent to (this allows locking the version of the sdk)
spaces checkout --script=workflows/preload --script=workflows/conan-sdk --name=conan-quick-test
```

This file serves as an example of how to preload a custom spaces starlark SDK.

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