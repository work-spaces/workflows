"""
Preload development script for workflows.

```
git clone https://github.com/work-spaces/workflows
spaces checkout --script=workflows/preload-dev --script=workflows/conan-sdk --name=conan-quick-test
```

This file serves as an example of how to preload a custom spaces starlark SDK.
"""

# Don't use load here - only built-ins because the loadable content is not available yet

checkout.add_repo(
    rule = {"name": "@sdk"},
    repo = {
        "url": "https://github.com/work-spaces/sdk",
        "rev": "main",
        "checkout": "Revision",
        "clone": "Blobless"
    }
)