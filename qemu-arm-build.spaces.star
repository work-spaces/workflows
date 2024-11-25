"""
Checkout script to build and publish qemu binaries.
"""

load("//spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")
load("//spaces-starlark-sdk/packages/github.com/astral-sh/uv/0.4.29.star", uv_platforms = "platforms")
load("//spaces-starlark-sdk/packages/github.com/astral-sh/ruff/0.8.0.star", ruff_platforms = "platforms")
load("//spaces-starlark-sdk/packages/github.com/cli/cli/v2.62.0.star", gh2_platforms = "platforms")
load("//spaces-starlark-sdk/star/python.star", "add_uv_python")
load("//spaces-starlark-sdk/star/gh.star", "add_publish_archive")
load(
    "//spaces-starlark-sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "checkout_add_repo",
    "checkout_add_which_asset",
    "checkout_update_env",
)
load("//spaces-starlark-sdk/star/run.star", "run_add_exec")

info.set_minimum_version("0.10.3")

checkout_add_platform_archive(
    "ninja1",
    platforms = ninja1_platforms,
)

checkout_add_platform_archive(
    "gh2",
    platforms = gh2_platforms,
)

add_uv_python(
    rule_name = "python3",
    uv_platforms = uv_platforms,
    ruff_platforms = ruff_platforms,
    python_version = "3.11",
    packages = ["meson"],
)

checkout_add_which_asset(
    "which_pkg_config",
    which = "pkg-config",
    destination = "sysroot/bin/pkg-config",
)

checkout_add_repo(
    "glib",
    url = "https://github.com/GNOME/glib",
    rev = "2.82.2",
    clone = "Worktree",
)

checkout_add_repo(
    "pixman",
    url = "https://gitlab.freedesktop.org/pixman/pixman",
    rev = "pixman-0.43.4",
    clone = "Worktree",
)

qemu_version = "7.2.9"

checkout_add_repo(
    "qemu",
    url = "https://github.com/qemu/qemu",
    rev = "v{}".format(qemu_version),
    clone = "Worktree",
)

def get_sdk_root():
    """
    Grab environment variables for QEMU build.

    Returns:
        dict: Environment variables for QEMU build.
    """
    if info.is_platform_macos():
        xcrun = process.exec(exec = {
            "command": "xcrun",
            "args": ["--show-sdk-path"],
        })

        if xcrun["status"] != 0:
            run.abort("Failed to get Xcode SDK path with xcrun: {}".format(xcrun["stderr"]))

        sdk_root = xcrun["stdout"].strip("\n")
        return sdk_root

    run.abort("Unsupported platform: {}".format(info.get_platform()))
    return ""

env_sdk_root = get_sdk_root()

checkout_update_env(
    "system_env",
    paths = ["/usr/bin", "/bin"],
)

# Run Rules

workspace = info.get_absolute_path_to_workspace()

install_prefix = "{}/build/install".format(workspace)
install_prefix_arg = "--prefix={}".format(install_prefix)
job_arg = "-j{}".format(info.get_cpu_count())
workspace_build_dir = "{}/build".format(workspace)

def meson_compile_and_install(rule_name, working_directory):
    build_rule_name = "{}_build".format(rule_name)
    run_add_exec(
        build_rule_name,
        deps = ["{}_configure".format(rule_name)],
        command = "meson",
        args = ["compile"],
        working_directory = working_directory,
    )

    run_add_exec(
        "{}_install".format(rule_name),
        deps = [build_rule_name],
        command = "meson",
        args = ["install"],
        working_directory = working_directory,
    )

def get_common_configure_args(build_dir):
    return [
        "configure",
        build_dir,
        "--prefix={}/build/install".format(workspace),
        "--buildtype=release",
        "--pkgconfig.relocatable",
    ]

run_add_exec(
    "glib_setup",
    command = "meson",
    args = ["setup", "build/glib", "glib"],
)

glib_common_configure_args = get_common_configure_args("../build/glib")
linux_configure_args = [
    "--default-library=static",
] if info.is_platform_linux() else []

run_add_exec(
    "glib_configure",
    deps = ["glib_setup"],
    command = "meson",
    args = glib_common_configure_args + linux_configure_args,
    working_directory = "glib",
)

meson_compile_and_install("glib", "build/glib")

run_add_exec(
    "pixman_setup",
    command = "meson",
    args = ["setup", "build/pixman", "pixman"],
)

pixman_common_configure_args = get_common_configure_args("{}/pixman".format(workspace_build_dir))

run_add_exec(
    "pixman_configure",
    deps = ["pixman_setup"],
    command = "meson",
    args = pixman_common_configure_args + linux_configure_args,
    working_directory = "pixman",
)

meson_compile_and_install("pixman", "build/pixman")

pkg_config_path = "{}/lib/pkgconfig".format(install_prefix) if info.is_platform_macos() else "{}/lib/x86_64-linux-gnu/pkgconfig".format(install_prefix)

run_add_exec(
    "qemu_setup",
    command = "mkdir",
    args = ["-p", "build/qemu"],
)

static_arg = ["--static"] if info.is_platform_linux() else []

run_add_exec(
    "qemu_configure",
    deps = ["glib_install", "qemu_setup", "pixman_install"],
    command = "../../qemu/configure",
    args = [
        "--python={}/venv/bin/python3".format(workspace),
        install_prefix_arg,
        "--target-list=arm-softmmu",
        "--disable-pie",
        "--disable-sdl",
        "--enable-fdt",
        "--disable-kvm",
        "--disable-xen",
        "--disable-guest-agent",
        "--disable-bsd-user",
    ] + static_arg,
    working_directory = "build/qemu",
    env = {"PKG_CONFIG_PATH": pkg_config_path},
)

run_add_exec(
    "qemu_ninja_build",
    deps = ["qemu_configure"],
    command = "ninja",
    args = ["-Cbuild/qemu"],
)

run_add_exec(
    "qemu_ninja_install",
    deps = ["qemu_ninja_build"],
    command = "ninja",
    args = ["-Cbuild/qemu", "install"],
)

def add_copy_libs():
    """
    Add targets to copy the dylibs using the relative paths
    """

    copy_libs = [
        {"name": "libpixman", "path": "build/pixman/pixman/libpixman-1.0.dylib"},
        {"name": "libglib", "path": "build/glib/glib/libglib-2.0.0.dylib"},
        {"name": "libgobject", "path": "build/glib/gobject/libgobject-2.0.0.dylib"},
        {"name": "libgthread", "path": "build/glib/gthread/libgthread-2.0.0.dylib"},
        {"name": "libgmodule", "path": "build/glib/gmodule/libgmodule-2.0.0.dylib"},
        {"name": "libgio", "path": "build/glib/gio/libgio-2.0.0.dylib"},
        {"name": "libgirepository", "path": "build/glib/girepository/libgirepository-2.0.0.dylib"},
    ]

    for lib in copy_libs:
        run_add_exec(
            "copy_{}".format(lib["name"]),
            deps = ["pixman_install", "glib_install"],
            command = "cp",
            args = ["-f", lib["path"], "build/install/lib/"],
        )

    deps = ["copy_{}".format(lib["name"]) for lib in copy_libs]

    run.add_target(
        rule = {"name": "copy_libs", "deps": deps},
    )

add_copy_libs()

run_add_exec(
    "install_qemu_rpath",
    deps = ["qemu_ninja_install", "copy_libs"],
    platforms = ["macos-x86_64", "macos-aarch64"],
    command = "install_name_tool",
    args = ["-add_rpath", "@executable_path/../lib", "build/install/bin/qemu-system-arm"],
)

add_publish_archive(
    name = "qemu-arm",
    input = "build/install",
    version = qemu_version,
    deploy_repo = "https://github.com/work-spaces/tools",
    deps = ["install_qemu_rpath"],
)
