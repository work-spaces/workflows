"""
Checkout script to build and publish qemu binaries.
"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")
load("spaces-starlark-sdk/packages/github.com/astral-sh/uv/0.4.29.star", uv_platforms = "platforms")
load("spaces-starlark-sdk/star/python.star", "add_uv_python")

load("spaces-starlark-sdk/packages/github.com/llvm/llvm-project/llvmorg-19.1.3.star", llvm19_platforms = "platforms")
load("spaces-starlark-sdk/star/llvm.star", "add_llvm")

add_llvm(
    rule_name = "llvm19",
    platforms = llvm19_platforms,
    toolchain_name = "llvm-19-toolchain.cmake")

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

checkout.add_repo(
    rule = {"name": "qemu"},
    repo = {
        "url": "https://github.com/qemu/qemu",
        "rev": "v7.2.9",
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

checkout.update_env(
    rule = {"name": "update_build_env"},
    env = {
        "vars": {
            "CC": "clang",
            "CXX": "clang++",
            "CC_LD": "lld",
            "CXX_LD": "lld",
            "SDKROOT": env_sdk_root,
            "CFLAGS": "-isysroot {}".format(env_sdk_root, env_sdk_root),
            "CXXFLAGS": "-isysroot {}".format(env_sdk_root, env_sdk_root),
            "LDFLAGS": "-fuse-ld=lld -isysroot {} -L{}/usr/lib".format(env_sdk_root, env_sdk_root),
        },
        "paths": []
    },
)

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

clang_env = {
    "CC": "{}/sysroot/bin/clang".format(workspace),
    "CXX": "{}/sysroot/bin/clang++".format(workspace),
}

def get_common_configure_args(build_dir):
    return [
        "configure",
        build_dir,
        "--prefix={}/build/install".format(workspace),
        "--buildtype=release",
        "--pkgconfig.relocatable",
    ]

#install_rpath_arg = ["-Dinstall_rpath='{}'".format("@loader_path" if info.is_platform_macos() else "$ORIGIN")]
install_rpath_arg = []

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
        "args": glib_common_configure_args + linux_configure_args + install_rpath_arg,
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
        "args": pixman_common_configure_args + linux_configure_args + install_rpath_arg,
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

run.add_exec(
    rule = {"name": "qemu_configure", "deps": ["glib_install", "qemu_setup", "pixman_install"]},
    exec = {
        "command": "../../qemu/configure",
        "args": [
            "--cc={}/sysroot/bin/clang".format(workspace),
            "--cxx={}/sysroot/bin/clang++".format(workspace),
            "--python={}/venv/bin/python3".format(workspace),
            install_prefix_arg,
            "--target-list=arm-softmmu",
            "--disable-pie",
            "--enable-fdt",
            "--disable-kvm",
            "--disable-xen",
        ] + ["--static"] if info.is_platform_linux() else None,
        "working_directory": "build/qemu",
        "env": {"PKG_CONFIG_PATH": pkg_config_path},
    },
)

run.add_exec(
    rule = {"name": "qemu_compile_commands", "deps": ["qemu_configure"]},
    exec = {
        "command": "ninja",
        "args": ["-Cbuild/qemu", "-tcompdb"],
    },
)

meson_compile_and_install("qemu", "build/qemu")
