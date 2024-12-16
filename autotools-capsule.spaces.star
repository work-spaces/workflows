"""

Autotools capsule workflow. This will install a copy of autotools in the capsules folder
in the spaces store.

"""

load(
    "//@sdk/star/checkout.star",
    "checkout_update_env",
)
load("//@sdk/star/capsule.star", "capsule_add_checkout_and_run")
load("//@sdk/star/gnu.star", "gnu_add_autotools_from_source")

autoconf_version = "2.72"
automake_version = "1.17"
libtool_version = "2.5.4"
capsule_name = "autotools"

def build_autotools():
    """
    Add the autotools checkout and run if the install path does not exist
    """
    install_path = capsule_get_install_path(capsule_name)
    if install_path != None:
        # the checkout and run rules are only added in the install path not None
        gnu_add_autotools_from_source(
            "autotools",
            autoconf_version,
            automake_version,
            libtool_version,
            install_path = install_path,
        )

capsule_add_checkout_and_run(
    "autotools",
)



# This is required to build this capsule. It does not affect consumers of the capsule.
checkout_update_env(
    "update_env",
    paths = ["/usr/bin", "/bin"],
)
