"""
Checkout script to build and publish qemu binaries.
"""

load("//@sdk/packages/star/github.com/packages.star", github_packages = "packages")
load("//@sdk/sdk/star/python.star", "python_add_uv")
load(
    "//@sdk/sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "checkout_add_repo",
    "checkout_update_env",
)
load("//@sdk/sdk/star/run.star", "run_add_exec")

info.set_minimum_version("0.11.2")

checkout_add_platform_archive(
    "ninja1",
    platforms = github_packages["ninja-build"]["ninja"]["v1.12.1"],
)

checkout_add_platform_archive(
    "spaces0",
    platforms = github_packages["work-spaces"]["spaces"]["v0.10.4"],
)

checkout_add_platform_archive(
    "gh2",
    platforms = github_packages["cli"]["cli"]["v2.62.0"],
)

checkout_add_platform_archive(
    "pkg_config0",
    platforms = github_packages["xpack-dev-tools"]["pkg-config-xpack"]["v0.29.2-3"],
)

python_add_uv(
    "python3",
    uv_version = "0.4.29",
    ruff_version = "0.8.0",
    python_version = "3.11",
    packages = ["meson"],
)

clone_type = "Blobless" if info.is_ci() else "Worktree"

checkout_add_repo(
    "glib",
    url = "https://github.com/GNOME/glib",
    rev = "2.82.2",
    clone = clone_type,
)

checkout_add_repo(
    "pixman",
    url = "https://gitlab.freedesktop.org/pixman/pixman",
    rev = "pixman-0.43.4",
    clone = clone_type,
)

qemu_version = "7.2.9"

checkout_add_repo(
    "qemu",
    url = "https://github.com/qemu/qemu",
    rev = "v{}".format(qemu_version),
    clone = clone_type,
)

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

def meson_compile_and_install(rule_name):
    build_rule_name = "{}_build".format(rule_name)
    working_directory = "build/{}".format(rule_name)
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

install_path = "{}/build/install".format(workspace)

def get_common_configure_args(build_dir):
    return [
        "configure",
        build_dir,
        "--prefix={}".format(install_path),
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

meson_compile_and_install("glib")

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

meson_compile_and_install("pixman")

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

run_add_exec(
    "install_bin_rpath_macos",
    deps = ["qemu_ninja_install"],
    command = "spaces-starlark-sdk/script/update-rpath-macos.star",
    args = [
        "--binary-path={}/bin".format(install_path),
        "--old-path={}".format(install_path),
        "--new-path=@executable_path/..",
    ],
)

run_add_exec(
    "install_lib_rpath_macos",
    deps = ["qemu_ninja_install"],
    command = "spaces-starlark-sdk/script/update-rpath-macos.star",
    args = [
        "--binary-path={}/lib".format(install_path),
        "--old-path={}/lib".format(install_path),
        "--new-path=@loader_path",
    ],
)

#add_publish_archive(
#    name = "qemu-arm",
#    input = "build/install",
#    version = qemu_version,
#    deploy_repo = "https://github.com/work-spaces/tools",
#    deps = ["install_qemu_rpath"],
#)
