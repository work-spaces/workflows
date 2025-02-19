"""
Building Ninja using Spaces
"""

load("//@star/packages/star/package.star", "package_add")
load("//@star/packages/star/cmake.star", "cmake_add")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_repo",
    "checkout_update_env",
)
load("//@star/sdk/star/run.star", "run_add_exec", "RUN_TYPE_ALL")
load("//@star/sdk/star/info.star", "info_set_minimum_version")
load("//@star/sdk/star/workspace.star", "workspace_get_absolute_path")

info_set_minimum_version("0.12.0")

cmake_add("cmake3", "v3.30.5")
package_add("github.com", "ninja-build", "ninja", "v1.12.1")

checkout_add_repo(
    "ninja-build",
    url = "https://github.com/ninja-build/ninja",
    rev = "v1.12.1",
    clone = "Worktree",
)

WORKSPACE = workspace_get_absolute_path()

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
checkout_update_env(
    "update_env",
    paths = ["/usr/bin", "/bin"],
    vars = {
        "SPACES_WORKSPACE": WORKSPACE,
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
        "-DCMAKE_INSTALL_PREFIX={}/build/install".format(WORKSPACE),
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
    type = RUN_TYPE_ALL,
    inputs = [
        "+build/ninja",
        "+ninja-build.spaces.star",
    ],
    deps = ["build"],
    command = "ninja",
    args = ["-Cbuild", "install"],
)


