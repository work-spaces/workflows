"""
Building Ninja using Spaces
"""

load("//spaces-starlark-sdk/packages/github.com/Kitware/CMake/v3.30.5.star", cmake3_platforms = "platforms")
load("//spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")
load("//spaces-starlark-sdk/packages/github.com/cli/cli/v2.62.0.star", gh2_platforms = "platforms")
load("//spaces-starlark-sdk/star/gh.star", "add_publish_archive")
load("//spaces-starlark-sdk/star/cmake.star", "add_cmake")
load(
    "//spaces-starlark-sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "checkout_add_repo",
    "checkout_update_env",
)
load("//spaces-starlark-sdk/star/run.star", "run_add_exec")

add_cmake(
    rule_name = "cmake3",
    platforms = cmake3_platforms,
)

checkout_add_platform_archive(
    "ninja1",
    platforms = ninja1_platforms,
)

checkout_add_platform_archive(
    "gh2",
    platforms = gh2_platforms,
)

checkout_add_repo(
    "ninja-build",
    url = "https://github.com/ninja-build/ninja",
    rev = "v1.12.1",
    clone = "Worktree",
)

workspace = info.get_absolute_path_to_workspace()

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
checkout_update_env(
    "update_env",
    paths = ["/usr/bin", "/bin"],
    vars = {
        "SPACES_WORKSPACE": workspace,
    },
)

run_add_exec(
    "configure",
    command = "cmake",
    args = [
        "-Bbuild",
        "-Sninja-build",
        "-Wno-dev",
        "-GNinja",
        "-DCMAKE_INSTALL_PREFIX={}/build/install".format(workspace),
    ],
)

run_add_exec(
    "build",
    deps = ["configure"],
    command = "cmake",
    args = ["--build", "build"],
)

run_add_exec(
    "install",
    deps = ["build"],
    command = "ninja",
    args = ["-Cbuild", "install"],
)

add_publish_archive(
    name = "ninja",
    input = "build/install",
    version = "1.12.1",
    deploy_repo = "https://github.com/work-spaces/tools",
    deps = ["install"],
    suffix = "tar.gz",
)
