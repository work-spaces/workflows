"""
Use HTTP headers to download the octocat image using an auth token.
"""

load("//@star/sdk/star/checkout.star",
    "checkout_add_archive")

load("//@star/sdk/star/run.star",
    "run_add_exec")

load("//@star/sdk/star/ws.star",
    "workspace_get_env_var",
    "workspace_is_env_var_set")

HEADERS = {
        "authorization": "Bearer {}".format(workspace_get_env_var("GH_TOKEN"))
    } if workspace_is_env_var_set("GH_TOKEN") else None

checkout_add_archive(
    name = "octocat",
    url = "https://api.github.com/octocat?s=hello",
    filename = "octocat.txt",
    sha256 = "0c0a21c35f83578f80a295c5c08231660ffe97ce384cfa9de5d8cc9f0dba9e92",
    headers = HEADERS
)

run_add_exec(
    name = "octocat_check",
    command = "ls",
    args = ["octocat.txt"]
)
