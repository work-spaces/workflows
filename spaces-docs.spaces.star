"""
Checks out a workspace to work on the spaces documentation.

"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_repo",
)
load("//@star/sdk/star/info.star", "info_set_required_semver")
info_set_required_semver(">0.10, <0.20.1")

checkout_add_repo(
    "work-spaces.github.io",
    url = "https://github.com/work-spaces/work-spaces.github.io/",
    rev = "main",
)

spaces_working_env()
