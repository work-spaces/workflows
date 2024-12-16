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
    "checkout_add_which_asset",
)
load("//@sdk/star/gnu.star", "gnu_add_configure_make_install_from_source")
load("//@sdk/star/gh.star", "gh_add")
load("//@sdk/star/spaces-env.star", "spaces_working_env")
load(
    "//@sdk/star/capsule.star",
    "capsule_add",
    "capsule_checkout_define_dependency",
    "capsule_get_install_path",
    "capsule_gh_add",
    "capsule_gh_publish",
)

load("//@sdk/star/rpath.star", "rpath_update_macos_install_dir")

gh_add(
    "gh2",
    version = "v2.62.0",
)

checkout_add_repo(
    "@capsules/capsules",
    url = "https://github.com/work-spaces/capsules",
    rev = "a2d7ba48a24eed157b706886d2368c07475f8c7e",
    clone = "Worktree",
)

checkout_add_which_asset(
    "which_spaces",
    which = "spaces",
    destination = "sysroot/bin/spaces")

capsule_checkout(
    "autotools_capsule",
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/autotools-capsule"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

repo = "m4"
m4_version = "1.4.19"
capsule_name = "m4"
deploy_repo = "https://github.com/work-spaces/capsules"

def add_checkout_and_run():
    """
    Add the autotools checkout and run if the install path does not exist
    """
    install_path = capsule_get_install_path(capsule_name)
    if install_path != None:
        # check to see if the capsule has a downloadable release
        platform_archive = capsule_gh_add(
            "m4_capsule",
            capsule_name,
            deploy_repo,
            suffix = "tar.gz",
        )

        if platform_archive == None:
            gnu_add_configure_make_install_from_source(
                "m4_from_source",
                "m4",
                "m4",
                m4_version,
                install_path = install_path,
            )

            # rewrites binary and shared library rpaths to make them relocatable
            rpath_update_macos_install_dir(
                "m4_update_macos_install_dir",
                install_path = install_path,
                deps = ["m4_from_source"],
            )

            # publish the binary packages for re-use
            capsule_gh_publish(
                "m4_capsule",
                capsule_name,
                deps = ["m4_update_macos_install_dir"],
                deploy_repo = deploy_repo,
                suffix = "tar.gz",
            )


add_checkout_and_run()

capsule_checkout_define_dependency(
    "{}_info".format(repo),
    capsule_name = capsule_name,
    domain = "ftp.gnu.org",
    owner = repo,
    repo = repo,
    version = m4_version,
)

spaces_working_env()
