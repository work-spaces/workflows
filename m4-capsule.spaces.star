"""

Build Autotools

Still a WIP.

TODO: 
- Publish binary packages to github releases?
- autoconf and others use perl and @INC does not get set correctly.
    - @INC needs to be runtime managed or autoconf should just be installed from source in the sysroot
"""

load(
    "//@sdk/star/checkout.star",
    "checkout_add_repo",
)
load("//@sdk/star/gnu-autotools.star", "gnu_add_configure_make_install_from_source")
load("//@sdk/star/spaces-env.star", "spaces_working_env")
load(
    "//@sdk/star/capsule.star",
    "capsule_add",
    "capsule_checkout_define_dependency",
    "capsule_dependency",
    "capsule_get_install_path",
)

checkout_add_repo(
    "@capsules/workflows",
    url = "https://github.com/work-spaces/workflows",
    rev = "6d045ab90d72c4b72cda63e78067c50c59f40c65",
    clone = "Default",
    is_evaluate_spaces_modules = False,
)

libtool2 = capsule_dependency("ftp.gnu.org", "libtool", "libtool", semver = "2")
automake1 = capsule_dependency("ftp.gnu.org", "automake", "automake", semver = "1")
autoconf2 = capsule_dependency("ftp.gnu.org", "autoconf", "autoconf", semver = ">=2.65")

capsule_add(
    "autotools_capsule",
    required = [libtool2, automake1, autoconf2],
    scripts = ["workflows/preload", "workflows/autotools-capsule"],
    deps = ["@capsules/workflows"],
    prefix = "sysroot",
)

gettext_version = "0.22"
m4_version = "1.4.19"
capsule_name = "build-essential"

def add_autotools_checkout_and_run():
    """
    Add the autotools checkout and run if the install path does not exist
    """
    install_path = capsule_get_install_path(capsule_name)
    if install_path != None:
        # the checkout and run rules are only added in the install path not None
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

        

def define_depedency(repo, version):
    capsule_checkout_define_dependency(
        "{}_info".format(repo),
        capsule_name = capsule_name,
        domain = "ftp.gnu.org",
        owner = repo,
        repo = repo,
        version = version,
    )

add_autotools_checkout_and_run()

define_depedency("gettext", gettext_version)
define_depedency("m4", m4_version)

spaces_working_env()
