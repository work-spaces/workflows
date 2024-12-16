"""
Oras test
"""

load("//@sdk/star/oras.star", "checkout_add_oras_archive")

checkout_add_oras_archive(
    "oras-get-ninja",
    url = "ghcr.io/work-spaces",
    artifact = "ninja-macos-x86_64",
    tag = "1.12.1",
    add_prefix = "sysroot"
)