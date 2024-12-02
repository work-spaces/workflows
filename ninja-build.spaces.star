"""
Building Ninja using Spaces
"""

load("//@packages/star/github.com/Kitware/CMake/v3.30.5.star", cmake3_platforms = "platforms")
load("//@packages/star/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")
load("//@packages/star/github.com/cli/cli/v2.62.0.star", gh2_platforms = "platforms")
load("//@sdk/star/gh.star", "gh_add_publish_archive")
load("//@sdk/star/cmake.star", "add_cmake")
load(
    "//@sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "checkout_add_repo",
    "checkout_update_env",
)
load("//@sdk/star/run.star", "run_add_exec")

info.set_minimum_version("0.11.2")

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
    inputs = [
        "+ninja-build/**/CMakeLists.txt",
        "+ninja-build.spaces.star",
    ],
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
    inputs = [
        "+ninja-build/src/**",
        "+build/build.ninja",
        "+ninja-build.spaces.star",
    ],
    deps = ["configure"],
    command = "ninja",
    args = ["-Cbuild"],
)

run_add_exec(
    "install",
    inputs = [
        "+build/ninja",
        "+ninja-build.spaces.star",
    ],
    deps = ["build"],
    command = "ninja",
    args = ["-Cbuild", "install"],
)

gh_add_publish_archive(
    name = "ninja",
    input = "build/install",
    version = "1.12.1",
    deploy_repo = "https://github.com/work-spaces/tools",
    deps = ["install"],
    suffix = "tar.gz",
)
