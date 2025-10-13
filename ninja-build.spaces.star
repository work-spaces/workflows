"""
Building Ninja using Spaces
"""

load("//@star/packages/star/package.star", "package_add")
load("//@star/packages/star/cmake.star", "cmake_add")
load("//@star/sdk/star/cmake.star", "cmake_add_configure_build_install")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_repo",
    "checkout_update_env",
)
load("//@star/sdk/star/run.star", "run_add_target", "RUN_TYPE_ALL")
load("//@star/sdk/star/info.star", "info_set_minimum_version")
load("//@star/sdk/star/ws.star", "workspace_get_absolute_path")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")

info_set_minimum_version("0.15.1")

spaces_working_env(add_spaces_to_sysroot = True, inherit_terminal = True)

cmake_add("cmake3", "v3.30.5")
package_add("github.com", "ninja-build", "ninja", "v1.12.1")

checkout_add_repo(
    "ninja-build",
    url = "https://github.com/ninja-build/ninja",
    rev = "v1.12.1",
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


cmake_add_configure_build_install(
    "cmake_ninja",
    source_directory = "ninja-build",
    configure_args = [
        "-Wno-dev",
        "-GNinja",
    ]
)

run_add_target(
    "install",
    type = RUN_TYPE_ALL,
    deps = ["cmake_ninja"],
)
