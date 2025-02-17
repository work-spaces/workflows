"""
Preload sources repo
"""

load("//@star/sdk/star/checkout.star", "checkout_add_repo")


checkout_add_repo(
    "@star/sources",
    url = "https://github.com/work-spaces/sources",
    rev = "main",
    clone = "Blobless"
)