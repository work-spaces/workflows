"""
This tests a subset of the packages available. It pulls the packages into the workspace
and then runs `<command> --version` to see if the executable is OK.

"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/packages/star/packages.star", "packages")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "update_platforms_prefix",
)
load("//@star/packages/star/python.star", "python_add_uv")
load("//@star/sdk/star/run.star", "RUN_TYPE_ALL", "run_add_exec")
load("//@star/packages/star/rust.star", "rust_add")
load("//@star/packages/star/sccache.star", "sccache_add")
load("//@star/packages/star/ccache.star", "ccache_add")
load("//@star/packages/star/package.star", "package_add")
load("//@star/packages/star/bazelisk.star", "bazelisk_add")
load("//@star/packages/star/shfmt.star", "shfmt_add")
load("//@star/packages/star/spaces-cli.star", "spaces_add")

package_add("nodejs.org", "node", "nodejs", "v23.3.0")
package_add("github.com", "cli", "cli", "v2.62.0")
package_add("github.com", "xpack-dev-tools", "qemu-arm-xpack", "v8.2.6-1")
package_add("github.com", "xpack-dev-tools", "pkg-config-xpack", "v0.29.2-3")
package_add("github.com", "oras-project", "oras", "v1.2.1")
package_add("github.com", "koalaman", "shellcheck", "v0.10.0")
bazelisk_add("bazelisk", "v1.25.0")
shfmt_add("shfmt", "v3.10.0")

SPACES0 = packages["github.com"]["work-spaces"]["spaces"]["v0.10.4"]

spaces_add(
    "spaces0",
    version = "v0.14.2",
    add_link_to_workspace_root = True,
)

SPACES_ALT = update_platforms_prefix(
    SPACES0,
    add_prefix = "sysroot/spaces/bin",
)

checkout_add_platform_archive(
    "spaces_alt",
    platforms = SPACES_ALT,
)

package_add("arm.developer.com", "gnu", "aarch64-none-elf", "13.3.rel1")
package_add("arm.developer.com", "gnu", "arm-none-eabi", "13.3.rel1")

python_add_uv(
    "uv_python",
    uv_version = "0.5.4",
    ruff_version = "0.8.0",
    python_version = "3.12",
    packages = ["black", "flake8", "mypy"],
)

rust_add(
    "rust_toolchain",
    version = "1.80",
)

sccache_add(
    "sccache",
    version = "0.8",
)

ccache_add("ccache", "v4.10.2")

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

def check_version(name):
    run_add_exec(
        "{}_test_version".format(name),
        type = RUN_TYPE_ALL,
        command = name,
        args = ["--version"],
        help = "Check the version of {}".format(name),
    )

def check_help(name):
    run_add_exec(
        "{}_test_help".format(name),
        type = RUN_TYPE_ALL,
        command = name,
        args = ["-h"],
        help = "Check the help of {}".format(name),
    )

COMMANDS = [
    "node",
    "npm",
    "npx",
    "cargo",
    "rustc",
    "gh",
    "uv",
    "ruff",
    "python",
    "spaces",
    "sysroot/spaces/bin/spaces",
    "aarch64-none-elf-gcc",
    "arm-none-eabi-gcc",
    "pkg-config",
    "shfmt",
    "ccache",
    "bazelisk",
    "shellcheck",
    "qemu-system-arm",
]
for name in COMMANDS:
    check_version(name)

check_help("oras")
