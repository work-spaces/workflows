"""

Build Autotools

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
    Get the install path for the capsule

    Args:
        name: The name of the capsule

    Returns:
        The install path for the capsule
    """
    digest_key = "SPACES_WORKSPACE_DIGEST"
    if info.is_env_var_set(digest_key):
        store = info.get_path_to_store()
        digest = info.get_env_var(digest_key)
        return "{}/capules/{}/{}".format(store, name, digest)
    return "build/install"

autoconf_version = "2.72"
automake_version = "1.17"
libtool_version = "2.5.4"

workspace = info.get_absolute_path_to_workspace()
install_path = "{}/build/install".format(workspace)

script.print("install_path: {}".format(capsule_get_install_path("autotools")))

gnu_add_autotools_from_source(
    "autotools",
    autoconf_version,
    automake_version,
    libtool_version,
    install_path = install_path,
)

checkout_update_asset(
    "libtool_capsule",
    destination = "capsules.json",
    value = {
        "capsules": [{
            "rule": "autotools_libtool",
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
    destination = "capsules.json",
    value = {
        "capsules": [{
            "rule": "autotools_libtool",
            "domain": "ftp.gnu.org",
            "owner": "automake",
            "repo": "automake",
            "version": automake_version,
            "is_relocatable": False,
        }],
    },
)


checkout_update_env(
    "update_env",
    paths = ["/usr/bin", "/bin"],
)
