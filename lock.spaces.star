"""
Spaces Workspace file
"""

WORKSPACE_LOCKS = {
  "//preload:@star/sdk": "v0.3.14",
  "//capsules-build:capsules": "23aace5161552c7d587b0dc137c2f5dcd70e7d0a",
  "//preload:@star/packages": "v0.2.22"
}

workspace.set_locks(locks = WORKSPACE_LOCKS)
