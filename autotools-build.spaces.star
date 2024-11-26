"""

Build Autotools

Still a WIP.

TODO: 
- Test install_name_tool on macOS.
- Publish binary packages to github releases.

"""

load("//spaces-starlark-sdk/star/checkout.star", "checkout_add_archive", "checkout_update_env", "checkout_add_which_asset")
load("//spaces-starlark-sdk/star/run.star", "run_add_exec")

gettext_version = "0.22"
gettext_sha256 = "0e60393a47061567b46875b249b7d2788b092d6457d656145bb0e7e6a3e26d93"
m4_version = "1.4.19"
m4_sha256 = "63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96"
autoconf_version = "2.72"
autoconf_sha256 = "ba885c1319578d6c94d46e9b0dceb4014caafe2490e437a0dbca3f270a223f5a"
automake_version = "1.17"
automake_sha256 = "8920c1fc411e13b90bf704ef9db6f29d540e76d232cb3b2c9f4dc4cc599bd990"
libtool_version = "2.5.4"
libtool_sha256 = "f81f5860666b0bc7d84baddefa60d1cb9fa6fceb2398cc3baca6afaa60266675"

cpu_count = info.get_cpu_count()
workspace = info.get_absolute_path_to_workspace()

checkout_add_archive(
    "gettext_download",
    url = "https://ftp.gnu.org/pub/gnu/gettext/gettext-{}.tar.xz".format(gettext_version),
    sha256 = gettext_sha256,
    add_prefix = "./",
)

checkout_add_which_asset(
    "which_spaces",
    which = "spaces",
    destination = "sysroot/bin/spaces"
)

checkout_add_archive(
    "m4_download",
    url = "https://ftp.gnu.org/gnu/m4/m4-{}.tar.xz".format(m4_version),
    sha256 = m4_sha256,
    add_prefix = "./",
)

checkout_add_archive(
    "autoconf_download",
    url = "https://ftp.gnu.org/gnu/autoconf/autoconf-{}.tar.xz".format(autoconf_version),
    sha256 = autoconf_sha256,
    add_prefix = "./",
)

checkout_add_archive(
    "automake_download",
    url = "https://ftp.gnu.org/gnu/automake/automake-{}.tar.xz".format(automake_version),
    sha256 = automake_sha256,
    add_prefix = "./",
)

checkout_add_archive(
    "libtool_download",
    url = "https://ftp.gnu.org/gnu/libtool/libtool-{}.tar.xz".format(libtool_version),
    sha256 = libtool_sha256,
    add_prefix = "./",
)

install_path = "{}/build/install".format(workspace)

checkout_update_env(
    "working_paths",
    paths = ["{}/bin".format(install_path), "/usr/bin", "/bin"],
)

def configure_build_install(name, version, deps, config):
    """
    Configure, build, and install a package.

    Args:
        name: The name of the package.
        version: The version of the package.
        deps: The dependencies of the package.
        config: The configuration options for the package.
    """

    prefix_arg = "--prefix={}".format(install_path)
    working_directory = "build/{}".format(name)
    build_dir_rule = "{}_build_dir".format(name)
    configure_rule = "{}_configure".format(name)
    build_rule = "{}_build".format(name)
    install_rule = "{}_install".format(name)

    run_add_exec(
        build_dir_rule,
        deps = deps,
        command = "mkdir",
        args = ["-p", working_directory],
    )

    run_add_exec(
        configure_rule,
        deps = [build_dir_rule],
        command = "../../{}-{}/configure".format(name, version),
        args = [prefix_arg] + config,
        working_directory = working_directory,
    )

    run_add_exec(
        build_rule,
        deps = [configure_rule],
        command = "make",
        args = ["-j{}".format(cpu_count)],
        working_directory = working_directory,
    )

    run_add_exec(
        install_rule,
        deps = [build_rule],
        command = "make",
        args = ["install"],
        working_directory = working_directory,
    )

def configure_build_install_all():
    """
    Configure, build, and install all packages.
    """
    packages = [
        {"name": "gettext", "version": gettext_version, "deps": None, "config": []},
        {"name": "m4", "version": m4_version, "deps": ["gettext_install"], "config": []},
        {"name": "autoconf", "version": autoconf_version, "deps": ["m4_install"], "config": []},
        {"name": "automake", "version": automake_version, "deps": ["autoconf_install"], "config": []},
        {"name": "libtool", "version": libtool_version, "deps": ["autoconf_install"], "config": []},
    ]

    for package in packages:
        configure_build_install(package["name"], package["version"], package["deps"], package["config"])

configure_build_install_all()

run_add_exec(
    "install_bin_rpath_macos",
    command = "spaces-starlark-sdk/script/update-rpath-macos.star",
    args = [
        "--binary-path={}/bin".format(install_path),
        "--old-path={}".format(install_path),
        "--new-path=@executable_path/../lib",
    ],
)

run_add_exec(
    "install_lib_rpath_macos",
    command = "spaces-starlark-sdk/script/update-rpath-macos.star",
    args = [
        "--binary-path={}/lib".format(install_path),
        "--old-path={}/lib".format(install_path),
        "--new-path=@loader_path",
    ],
)
