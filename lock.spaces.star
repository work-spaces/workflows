"""
Spaces Workspace file
"""

WORKSPACE_LOCKS = {
  "//preload:@star/sdk": "v0.3.6",
  "//capsules-build:capsules": "23aace5161552c7d587b0dc137c2f5dcd70e7d0a",
  "//preload:@star/packages": "8601471368967f265773f73bb13bdfbe733e702f"
}

workspace.set_locks(locks = WORKSPACE_LOCKS) 
