"""
Building Ninja using Spaces
"""

load("spaces-starlark-sdk/packages/github.com/Kitware/CMake/v3.30.5.star", cmake3_platforms = "platforms")
load("spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")
load("spaces-starlark-sdk/star/cmake.star", "add_cmake")
load("spaces-starlark-sdk/star/checkout.star", "checkout_add_repo")
load("spaces-starlark-sdk/star/run.star", "run_add_exec")

add_cmake(
    rule_name = "cmake3",
    platforms = cmake3_platforms,
)

checkout.add_platform_archive(
    rule = {"name": "ninja1"},
    platforms = ninja1_platforms,
)

checkout_add_repo(
    "ninja-build",
    url = "https://github.com/ninja-build/ninja",
    rev = "v1.12.1",
    clone = "Worktree",
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
#spaces_working_env()

workspace = info.get_absolute_path_to_workspace()

run_env = {
    "PATH": "{}/sysroot/bin:/usr/bin:/bin".format(workspace),
}

run_add_exec(
    "configure",
    command = "cmake",
    args = ["-Bbuild", "-Sninja-build", "-Wno-dev", "-GNinja"],
    env = run_env,
)

run_add_exec(
    "build",
    deps = ["configure"],
    command = "cmake",
    args = ["--build", "build"],
    env = run_env,
)
