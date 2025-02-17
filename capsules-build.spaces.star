"""

Create a workspace using the autotools capsule.

WIP: porting to starlark based capsule system.

"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/sdk/star/checkout.star", "checkout_add_repo")
load("//@star/packages/star/cmake.star", "cmake_add")
load("//@star/packages/star/spaces-cli.star", "spaces_add")


spaces_working_env()
cmake_add("cmake3", "v3.31.3")
spaces_add("spaces0", "v0.12.6")

checkout_add_repo(
    "capsules",
    url = "https://github.com/work-spaces/capsules",
    rev = "main",
    clone = "Blobless"
)