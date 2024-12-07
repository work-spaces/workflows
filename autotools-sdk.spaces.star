"""

Create a workspace using the autotools capsule.

"""

load(
    "//@sdk/star/checkout.star",
    "checkout_add_repo",
    "checkout_update_env",
)

checkout_add_repo(
    "@capsules/workflows",
    url = "https://github.com/work-spaces/workflows",
    rev = "0e62aac19470fb3d0fcdb44a6d857193ab5d687f",
    clone = "Default",
    is_evaluate_spaces_modules = False,
)

descriptor_base = {
    "domain": "ftp.gnu.org",
}

checkout.add_capsule(
    rule = {"name": "autotools_capsule", "deps": ["@capsules/workflows"]},
    capsule = {
        "required": [
            {
                "descriptor": descriptor_base | {
                    "owner": "libtool",
                    "repo": "libtool",
                },
                "semver": "2",
                "dependency_type": "Build",
            },
            {
                "descriptor": descriptor_base | {
                    "owner": "automake",
                    "repo": "automake",
                },
                "semver": "1",
                "dependency_type": "Build",
            },
            {
                "descriptor": descriptor_base | {
                    "owner": "autoconf",
                    "repo": "autoconf",
                },
                "semver": ">=2.65",
                "dependency_type": "Build",
            },
        ],
        "scripts": ["workflows/preload", "workflows/autotools-capsule"],
        "name": "autotools-capsule",
        "version": "1.0.0",
    },
)

checkout_update_env(
    "update_env",
    paths = ["/usr/bin", "/bin"],
)
