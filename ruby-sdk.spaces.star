"""
Sample workflow for consuming capsules.
"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/sdk/star/oras.star", "oras_add_platform_archive")


spaces_working_env()

oras_add_platform_archive(
    "ruby-v3",
    url = "ghcr.io/work-spaces",
    artifact = "ruby-lang.org-ruby-ruby",
    tag = "3.4.1-66a9004f"
)


