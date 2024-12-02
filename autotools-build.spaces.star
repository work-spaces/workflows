"""

Build Autotools

Still a WIP.

TODO: 
- Publish binary packages to github releases?
- autoconf and others use perl and @INC does not get set correctly.
    - @INC needs to be runtime managed or autoconf should just be installed from source in the sysroot
"""

load(
    "//@packages/star/github.com/packages.star",
    github_packages = "packages",
)
load(
    "//@sdk/star/checkout.star",
    "checkout_add_platform_archive",
    "checkout_update_env",
)
load("//@sdk/star/rpath.star", "rpath_update_macos_install_dir")
load("//@sdk/star/gnu-autotools.star", "gnu_add_autotools_from_source", "gnu_add_configure_make_install_from_source")

autoconf_version = "2.72"
automake_version = "1.17"
libtool_version = "2.5.4"

cpu_count = info.get_cpu_count()
workspace = info.get_absolute_path_to_workspace()
install_path = "{}/build/install".format(workspace)

checkout_add_platform_archive(
    "m4-1",
    platforms = github_packages["xpack-dev-tools"]["m4-xpack"]["v1.4.19-3"],
)

checkout_add_platform_archive(
    "spaces0",
    platforms = github_packages["work-spaces"]["spaces"]["v0.10.4"],
)

gnu_add_autotools_from_source(
    "autotools",
    autoconf_version,
    automake_version,
    libtool_version,
    install_path = install_path,
)

'''
gettext_version = "0.22"
m4_version = "1.4.19"
gnu_add_configure_make_install_from_source(
    "gettext_from_source",
    "gettext",
    "gettext",
    gettext_version,
    install_path = install_path,
)

gnu_add_configure_make_install_from_source(
    "m4_from_source",
    "m4",
    "m4",
    m4_version,
    install_path = install_path,
)
'''

checkout_update_env(
    "working_paths",
    paths = ["{}/bin".format(install_path)],
    system_paths = ["/usr/bin", "/bin"],
)

rpath_update_macos_install_dir(
    "update_macos_rpaths",
    install_path,
    deps = ["autotools"],
)

