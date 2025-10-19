"""
Use HTTP headers to download the octocat image using an auth token.
"""

load("//@star/sdk/star/checkout.star",
    "checkout_update_env")


checkout_update_env(
    "gh_token",
    optional_inherited_vars = ["GH_TOKEN"]
)
