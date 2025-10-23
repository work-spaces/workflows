"""
This tests a subset of the packages available. It pulls the packages into the workspace
and then runs `<command> --version` to see if the executable is OK.

"""

load("//@star/packages/star/bazelisk.star", "bazelisk_add")
load("//@star/packages/star/buildifier.star", "buildifier_add")
load("//@star/packages/star/ccache.star", "ccache_add")
load(
    "//@star/packages/star/coreutils.star",
    "coreutils_add",
    coreutils_default_functions = "DEFAULT_FUNCTIONS",
    "coreutils_add_rs_tools"
)
load("//@star/packages/star/package.star", "package_add")
load("//@star/packages/star/packages.star", "packages")
load("//@star/packages/star/python.star", "python_add_uv")
load("//@star/packages/star/rust.star", "rust_add")
load("//@star/packages/star/sccache.star", "sccache_add")
load("//@star/packages/star/shfmt.star", "shfmt_add")
load("//@star/packages/star/spaces-cli.star", "spaces_add")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "update_platforms_prefix",
    "checkout_add_cargo_bin",
)
load("//@star/sdk/star/info.star", "info_set_required_semver")
load("//@star/sdk/star/run.star", "RUN_TYPE_ALL", "run_add_exec", "run_expect_failure", "run_expect_success")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")

package_add("nodejs.org", "node", "nodejs", "v23.3.0")
package_add("github.com", "cli", "cli", "v2.62.0")
package_add("github.com", "xpack-dev-tools", "qemu-arm-xpack", "v8.2.6-1")
package_add("github.com", "xpack-dev-tools", "pkg-config-xpack", "v0.29.2-3")
package_add("github.com", "oras-project", "oras", "v1.2.1")
package_add("github.com", "koalaman", "shellcheck", "v0.10.0")
package_add("github.com", "gohugoio", "hugo", "v0.145.0")
package_add("github.com", "jqlang", "jq", "jq-1.7.1")
package_add("github.com", "git-lfs", "git-lfs", "v3.6.1")
bazelisk_add("bazelisk", "v1.25.0")
buildifier_add("buildifier", "v8.2.1")
coreutils_add("coreutils", "0.2.2")
shfmt_add("shfmt", "v3.10.0")

SPACES0 = packages["github.com"]["work-spaces"]["spaces"]["v0.10.4"]

info_set_required_semver(">0.10, <0.20.1")

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


coreutils_add_rs_tools("rs-tools")
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
    "aarch64-none-elf-gcc",
    "arm-none-eabi-gcc",
    "bazelisk",
    "buildifier",
    "cargo",
    "ccache",
    "gh",
    "jq",
    "git-lfs",
    "node",
    "npm",
    "npx",
    "pkg-config",
    "python",
    "qemu-system-arm",
    "ruff",
    "rustc",
    "shellcheck",
    "shfmt",
    "spaces",
    "sysroot/spaces/bin/spaces",
    "uv",
]
for name in COMMANDS:
    check_version(name)

for function in coreutils_default_functions:
    expect = run_expect_success() if function != "false" else run_expect_failure()

    run_add_exec(
        "{}_coreutils_version".format(function),
        type = RUN_TYPE_ALL,
        command = "coreutils",
        args = [function, "--version"],
        expect = expect,
        help = "Check the version of {} coreutils function".format(name),
    )

HELP_COMMANDS = [
    "hugo",
    "oras",
]

for name in HELP_COMMANDS:
    check_help(name)
