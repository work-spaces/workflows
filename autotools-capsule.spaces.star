"""

Define autotools as a capsule

Still a WIP.

"""

load(
    "//@sdk/star/checkout.star",
    "checkout_update_asset",
    "checkout_update_env",
)
load("//@sdk/star/run.star", "run_add_target")
load("//@sdk/star/gnu-autotools.star", "gnu_add_autotools_from_source")

capsule_name = "autotools"
capsule_rule_prefix = "{}-capsule".format(capsule_name)
workspace = info.get_absolute_path_to_workspace()

def capsule_get_install_path(name):
    """
    Check if the capsule is required to be checked out and run

    Args:
        name: The name of the capsule

    Returns:
        True if the capsule is required to be checked out and run, False otherwise
    """
    store = info.get_path_to_store()
    digest = info.get_workspace_digest()
    install_path = "{}/capules/{}/{}".format(store, name, digest)
    if fs.exists(install_path):
        return None
    return install_path

def capsule_get_prefix(name):
    """
    Get the prefix of the capsule

    Args:
        name: The name of the capsule

    Returns:
        The prefix of the capsule
    """
    store = info.get_path_to_store()
    digest = info.get_workspace_digest()
    return "{}/capules/{}/{}".format(store, name, digest)

autoconf_version = "2.72"
automake_version = "1.17"
libtool_version = "2.5.4"

def add_autotools_checkout_and_run():
    """
    Add the autotools checkout and run if the install path does not exist
    """
    install_path = capsule_get_install_path(capsule_name)
    if install_path != None:
        gnu_add_autotools_from_source(
            "autotools",
            autoconf_version,
            automake_version,
            libtool_version,
            install_path = install_path,
        )
    else:
        run_add_target(
            "autotools_libtool",
            deps = [],
        )
        run_add_target(
            "autotools_automake",
            deps = [],
        )
        run_add_target(
            "autotools_autoconf",
            deps = [],
        )

add_autotools_checkout_and_run()

prefix = capsule_get_prefix(capsule_name)

descriptor_base = {
    "domain": "ftp.gnu.org",
    "owner": "libtool",
}

checkout_update_asset(
    "libtool_capsule",
    destination = "capsules.spaces.json",
    value = [{
        "rule": "{}:autotools_libtool".format(capsule_rule_prefix),
        "desriptor": descriptor_base | {
            "repo": "libtool",
        },
        "version": libtool_version,
        "is_relocatable": False,
        "prefix": prefix,
        "workspace": workspace
    }],
)

checkout_update_asset(
    "automake_capsule",
    destination = "capsules.spaces.json",
    value = [{
        "rule": "{}:autotools_automake".format(capsule_rule_prefix),
        "desriptor": descriptor_base | {
            "repo": "automake",
        },
        "version": automake_version,
        "is_relocatable": False,
        "prefix": prefix,
        "workspace": workspace
    }],
)

checkout_update_asset(
    "automake_capsule",
    destination = "capsules.spaces.json",
    value = [{
        "rule": "{}:autotools_autoconf".format(capsule_rule_prefix),
        "desriptor": descriptor_base | {
            "repo": "autoconf",
        },
        "version": autoconf_version,
        "is_relocatable": False,
        "prefix": prefix,
        "workspace": workspace
    }],
)

checkout_update_env(
    "update_env",
    paths = ["/usr/bin", "/bin"],
)
