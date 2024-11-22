"""
Building Ninja using Spaces
"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("spaces-starlark-sdk/packages/github.com/Kitware/CMake/v3.30.5.star", cmake3_platforms = "platforms")
load("spaces-starlark-sdk/star/cmake.star", "add_cmake")
load("spaces-starlark-sdk/star/checkout.star", "add_clone_repo")
load("spaces-starlark-sdk/star/run.star", "add_exec")

add_cmake(
    rule_name = "cmake3",
    platforms = cmake3_platforms,
)

add_clone_repo(
    "ninja-build",
    url = "https://github.com/ninja-build/ninja",
    rev = "v1.12.1",
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

add_exec(
    "configure",
    command = "cmake",
    args = ["-Bbuild", "-Sninja-build", "-Wno-dev"],
)

add_exec(
    "build",
    command = "cmake",
    args = ["--build", "build"],
)
