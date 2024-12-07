"""

Define autotools as a capsule

Still a WIP.

"""

load(
    "//@sdk/star/checkout.star",
    "checkout_update_asset",
    "checkout_update_env",
)
load("//@sdk/star/gnu-autotools.star", "gnu_add_autotools_from_source")

def capsule_get_install_path(name):
    """
    Check if the capsule is required to be checked out and run

    Args:
        name: The name of the capsule

    Returns:
        True if the capsule is required to be checked out and run, False otherwise
    """
    digest = info.get_workspace_digest()
    install_path = "{}/capules/{}/{}".format(store, name, digest)
    if fs.exists(install_path):
        return None
    return install_path

install_path = capsule_get_install_path("autotools")

autoconf_version = "2.72"
automake_version = "1.17"
libtool_version = "2.5.4"

def add_autotools_checkout_and_run():
    """
    Add the autotools checkout and run if the install path does not exist
    """
    install_path = capsule_get_install_path("autotools")
    if install_path != None:
        digest = info.get_workspace_digest()
        install_path = "{}/capules/autotools/{}".format(store, digest)
        gnu_add_autotools_from_source(
            "autotools",
            autoconf_version,
            automake_version,
            libtool_version,
            install_path = install_path,
        )

add_autotools_checkout_and_run()

checkout_update_asset(
    "libtool_capsule",
    destination = "capsules.spaces.json",
    value = {
        "capsules": [{
            "rule": "autotools-capsule:autotools_libtool",
            "domain": "ftp.gnu.org",
            "owner": "libtool",
            "repo": "libtool",
            "version": libtool_version,
            "is_relocatable": False,
        }],
    },
)

checkout_update_asset(
    "automake_capsule",
    destination = "capsules.spaces.json",
    value = {
        "capsules": [{
            "rule": "autotools-capsule:autotools_automake",
            "domain": "ftp.gnu.org",
            "owner": "automake",
            "repo": "automake",
            "version": automake_version,
            "is_relocatable": False,
        }],
    },
)

checkout_update_asset(
    "automake_capsule",
    destination = "capsules.spaces.json",
    value = {
        "capsules": [{
            "rule": "autotools-capsule:autotools_autoconf",
            "domain": "ftp.gnu.org",
            "owner": "autoconf",
            "repo": "autoconf",
            "version": autoconf_version,
            "is_relocatable": False,
        }],
    },
)


checkout_update_env(
    "update_env",
    paths = ["/usr/bin", "/bin"],
)
