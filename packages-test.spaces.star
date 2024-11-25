"""
This tests a subset of the packages available. It pulls the packages into the workspace
and then runs `<command> --version` to see if the executable is OK.

"""

load("//spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("//spaces-starlark-sdk/packages/nodejs.org/node/nodejs/v23.3.0.star", node23 = "platforms")
load("//spaces-starlark-sdk/packages/github.com/cli/cli/v2.62.0.star", gh2 = "platforms")
load("//spaces-starlark-sdk/packages/github.com/astral-sh/ruff/0.8.0.star", ruff0 = "platforms")
load("//spaces-starlark-sdk/packages/github.com/astral-sh/uv/0.5.4.star", uv0 = "platforms")
load("//spaces-starlark-sdk/packages/github.com/xpack-dev-tools/pkg-config-xpack/v0.29.2-3.star", pkg_config0 = "platforms")
load("//spaces-starlark-sdk/packages/github.com/xpack-dev-tools/qemu-arm-xpack/v8.2.6-1.star", qemu_arm8 = "platforms")
load("//spaces-starlark-sdk/packages/github.com/work-spaces/tools/qemu-arm-v7.2.9.star", qemu_arm7 = "platforms")
load("//spaces-starlark-sdk/packages/arm.developer.com/gnu/aarch64-none-elf/13.3.rel1.star", gnu_aarch_none_elf13 = "platforms")
load("//spaces-starlark-sdk/packages/arm.developer.com/gnu/arm-none-eabi/13.3.rel1.star", gnu_arm_none_eabi13 = "platforms")
load("//spaces-starlark-sdk/packages/github.com/work-spaces/spaces/v0.10.4.star", spaces0 = "platforms")
load(
    "//spaces-starlark-sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "update_platforms_prefix",
)
load("//spaces-starlark-sdk/star/python.star", "add_uv_python")
load("//spaces-starlark-sdk/star/run.star", "run_add_exec")
load("//spaces-starlark-sdk/star/rust.star", "add_rust")
load("//spaces-starlark-sdk/star/sccache.star", "add_sccache")

checkout_add_platform_archive(
    "nodejs23",
    platforms = node23,
)

checkout_add_platform_archive(
    "gh2",
    platforms = gh2,
)

checkout_add_platform_archive(
    "qemu_arm8",
    platforms = qemu_arm8,
)

qemu7_alt = update_platforms_prefix(
    qemu_arm7,
    add_prefix = "sysroot/qemu-7",
)

checkout_add_platform_archive(
    "qemu_arm7",
    platforms = qemu7_alt,
)

checkout_add_platform_archive(
    "pkg_config0",
    platforms = pkg_config0,
)

checkout_add_platform_archive(
    "spaces0",
    platforms = spaces0,
)

spaces_alt = update_platforms_prefix(
    spaces0,
    add_prefix = "sysroot/spaces/bin",
)

checkout_add_platform_archive(
    "spaces_alt",
    platforms = spaces_alt,
)

checkout_add_platform_archive(
    "gnu_aarch_none_elf13",
    platforms = gnu_aarch_none_elf13,
)

checkout_add_platform_archive(
    "gnu_arm_none_eabi13",
    platforms = gnu_arm_none_eabi13,
)

add_uv_python(
    "uv_python",
    uv_platforms = uv0,
    ruff_platforms = ruff0,
    python_version = "3.12",
    packages = ["black", "flake8", "mypy"],
)

add_rust(
    rule_name = "rust_toolchain",
    toolchain_version = "1.80",
)

add_sccache(
    rule_name = "sccache",
    sccache_version = "0.8",
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

def check_version(name):
    run_add_exec(
        "{}_test_version".format(name),
        command = name,
        args = ["--version"],
        help = "Check the version of {}".format(name),
    )

def check_versions():
    commands = [
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
        "qemu-system-arm",
        "sysroot/qemu-7/bin/qemu-system-arm",
    ]
    for name in commands:
        check_version(name)

check_versions()
