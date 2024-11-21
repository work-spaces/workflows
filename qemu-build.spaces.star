"""
Checkout script to build and publish qemu binaries.
"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")
load("spaces-starlark-sdk/packages/github.com/astral-sh/uv/0.4.29.star", uv_platforms = "platforms")
load("spaces-starlark-sdk/star/python.star", "add_uv_python")

info.set_minimum_version("0.10.0")

checkout.add_platform_archive(
    rule = {"name": "ninja1"},
    platforms = ninja1_platforms,
)

add_uv_python(
    rule_name = "python3",
    uv_platforms = uv_platforms,
    python_version = "3.11",
    packages = ["meson"],
)

checkout.add_which_asset(
    rule = {"name": "which_pkg_config"},
    asset = {
        "which": "pkg-config",
        "destination": "sysroot/bin/pkg-config",
    },
)

checkout.add_repo(
    rule = {"name": "glib"},
    repo = {
        "url": "https://github.com/GNOME/glib",
        "rev": "2.82.2",
        "checkout": "Revision",
        "clone": "Worktree",
    },
)

checkout.add_repo(
    rule = {"name": "pixman"},
    repo = {
        "url": "https://gitlab.freedesktop.org/pixman/pixman",
        "rev": "pixman-0.43.4",
        "checkout": "Revision",
        "clone": "Worktree",
    },
)

qemu_version = "7.2.9"

checkout.add_repo(
    rule = {"name": "qemu"},
    repo = {
        "url": "https://github.com/qemu/qemu",
        "rev": "v{}".format(qemu_version),
        "checkout": "Revision",
        "clone": "Worktree",
    },
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

spaces_working_env()

# Run Rules

workspace = info.get_absolute_path_to_workspace()

install_prefix = "{}/build/install".format(workspace)
install_prefix_arg = "--prefix={}".format(install_prefix)
job_arg = "-j{}".format(info.get_cpu_count())
workspace_build_dir = "{}/build".format(workspace)

def meson_compile_and_install(rule_name, working_directory):
    build_rule_name = "{}_build".format(rule_name)
    run.add_exec(
        rule = {"name": build_rule_name, "deps": ["{}_configure".format(rule_name)]},
        exec = {
            "command": "meson",
            "args": ["compile"],
            "working_directory": working_directory,
        },
    )

    run.add_exec(
        rule = {"name": "{}_install".format(rule_name), "deps": [build_rule_name]},
        exec = {
            "command": "meson",
            "args": ["install"],
            "working_directory": working_directory,
        },
    )

def get_common_configure_args(build_dir):
    return [
        "configure",
        build_dir,
        "--prefix={}/build/install".format(workspace),
        "--buildtype=release",
        "--pkgconfig.relocatable",
    ]

run.add_exec(
    rule = {"name": "glib_setup"},
    exec = {
        "command": "meson",
        "args": ["setup", "build/glib", "glib"],
    },
)

glib_common_configure_args = get_common_configure_args("../build/glib")
linux_configure_args = [
    "--default-library=static",
] if info.is_platform_linux() else []

run.add_exec(
    rule = {"name": "glib_configure", "deps": ["glib_setup"]},
    exec = {
        "command": "meson",
        "args": glib_common_configure_args + linux_configure_args,
        "working_directory": "glib",
    },
)

meson_compile_and_install("glib", "build/glib")

run.add_exec(
    rule = {"name": "pixman_setup"},
    exec = {
        "command": "meson",
        "args": ["setup", "build/pixman", "pixman"],
    },
)

pixman_common_configure_args = get_common_configure_args("{}/pixman".format(workspace_build_dir))

run.add_exec(
    rule = {"name": "pixman_configure", "deps": ["pixman_setup"]},
    exec = {
        "command": "meson",
        "args": pixman_common_configure_args + linux_configure_args,
        "working_directory": "pixman",
    },
)

meson_compile_and_install("pixman", "build/pixman")

pkg_config_path = "{}/lib/pkgconfig".format(install_prefix) if info.is_platform_macos() else "{}/lib/x86_64-linux-gnu/pkgconfig".format(install_prefix)

run.add_exec(
    rule = {"name": "qemu_setup"},
    exec = {
        "command": "mkdir",
        "args": ["-p", "build/qemu"],
    },
)

static_arg = ["--static"] if info.is_platform_linux() else []

run.add_exec(
    rule = {"name": "qemu_configure", "deps": ["glib_install", "qemu_setup", "pixman_install"]},
    exec = {
        "command": "../../qemu/configure",
        "args": [
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
        "working_directory": "build/qemu",
        "env": {"PKG_CONFIG_PATH": pkg_config_path},
    },
)

run.add_exec(
    rule = {"name": "qemu_ninja_build", "deps": ["qemu_configure"]},
    exec = {
        "command": "ninja",
        "args": ["-Cbuild/qemu"],
    },
)

run.add_exec(
    rule = {"name": "qemu_ninja_install", "deps": ["qemu_ninja_build"]},
    exec = {
        "command": "ninja",
        "args": ["-Cbuild/qemu", "install"],
    },
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
        run.add_exec(
            rule = {"name": "copy_{}".format(lib["name"]), "deps": ["pixman_install", "glib_install"]},
            exec = {
                "command": "cp",
                "args": ["-f", lib["path"], "build/install/lib/"],
            },
        )

    deps = ["copy_{}".format(lib["name"]) for lib in copy_libs]

    run.add_target(
        rule = {"name": "copy_libs", "deps": deps},
    )

add_copy_libs()

run.add_exec(
    rule = {
        "name": "install_qemu_rpath",
        "deps": ["qemu_ninja_install", "copy_libs"],
        "platforms": ["macos-x86_64", "macos-aarch64"],
    },
    exec = {
        "command": "install_name_tool",
        "args": ["-add_rpath", "@executable_path/../lib", "build/install/bin/qemu-system-arm"],
    },
)

archive_info = {
    "input": "build/install",
    "name": "qemu",
    "version": qemu_version,
    "driver": "tar.xz",
    "platform": info.get_platform_name(),
}

#archive_output = info.get_path_to_build_archive(rule_name = archive_rule_name, archive = archive_info)

run.add_archive(
    rule = {"name": "archive_qemu", "deps": ["install_qemu_rpath"]},
    archive = archive_info,
)
