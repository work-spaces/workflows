"""
Building Ninja using Spaces
"""

load("//@star/packages/star/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")
load("//@star/sdk/star/oras.star", "oras_add_publish_archive")
load("//@star/sdk/star/cmake.star", "cmake_add")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "checkout_add_repo",
    "checkout_update_env",
)
load("//@star/sdk/star/run.star", "run_add_exec")

info.set_minimum_version("0.11.6")

cmake_add(
    "cmake3",
    version = "v3.30.5",
)

checkout_add_platform_archive(
    "ninja1",
    platforms = ninja1_platforms,
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
    inherited_vars = ["HOME"],
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

oras_add_publish_archive(
    name = "ninja",
    input = "build/install",
    tag = "v1.12.1",
    url = "ghcr.io/work-spaces",
    artifact = "ninja-build-non-reproducible-{}".format(info.get_platform_name()),
    deps = ["install"],
    suffix = "tar.gz",
)


