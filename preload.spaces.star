"""
Preload script for this workspace.

The spaces-starlark-sdk can be preloaded using: `--spaces-starlark-sdk`.

```
git clone https://github.com/work-spaces/workflows
spaces checkout --script=workflows/preload --script=workflows/conan-sdk --name=conan-quick-test
```

This file serves as an example of how to preload a custom spaces starlark SDK.

"""

checkout.update_env(
    rule = {"name": "workspace_env"},
    env = {
        "vars": {},
        "paths": ["{}/sysroot/bin".format(workspace.get_absolute_path())]
    }
)

checkout.add_repo(
    rule = {"name": "@star/sdk"},
    repo = {
        "url": "https://github.com/work-spaces/sdk",
        "rev": "main",
        "checkout": "Revision",
        "clone": "Default"
    }
)

checkout.add_repo(
    rule = {"name": "@star/packages"},
    repo = {
        "url": "https://github.com/work-spaces/packages",
        "rev": "main",
        "checkout": "Revision",
        "clone": "Default"
    }
)
