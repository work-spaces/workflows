"""
This tests a subset of the packages available. It pulls the packages into the workspace
and then runs `<command> --version` to see if the executable is OK.

"""

load("//@sdk/star/spaces-env.star", "spaces_working_env")
load("//@packages/star/packages.star", "packages")
load(
    "//@sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "update_platforms_prefix",
)
load("//@sdk/star/python.star", "python_add_uv")
load("//@sdk/star/run.star", "run_add_exec")
load("//@sdk/star/rust.star", "rust_add")
load("//@sdk/star/sccache.star", "sccache_add")

checkout_add_platform_archive(
    "nodejs23",
    platforms = packages["nodejs.org"]["node"]["nodejs"]["v23.3.0"],
)

checkout_add_platform_archive(
    "gh2",
    platforms = packages["github.com"]["cli"]["cli"]["v2.62.0"],
)

checkout_add_platform_archive(
    "qemu_arm8",
    platforms = packages["github.com"]["xpack-dev-tools"]["qemu-arm-xpack"]["v8.2.6-1"],
)

checkout_add_platform_archive(
    "pkg_config0",
    platforms = packages["github.com"]["xpack-dev-tools"]["pkg-config-xpack"]["v0.29.2-3"],
)

spaces0 = packages["github.com"]["work-spaces"]["spaces"]["v0.10.4"]

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
    platforms = packages["arm.developer.com"]["gnu"]["aarch64-none-elf"]["13.3.rel1"],
)

checkout_add_platform_archive(
    "gnu_arm_none_eabi13",
    platforms = packages["arm.developer.com"]["gnu"]["arm-none-eabi"]["13.3.rel1"],
)

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
    ]
    for name in commands:
        check_version(name)

check_versions()
