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
    rev = "d2ba17701d1db8325ef92a9fd5a3c8a930cea3fc",
    clone = "Default",
    is_evaluate_spaces_modules = False,
)

descriptor_base = {
    "domain": "ftp.gnu.org",
    "owner": "libtool",
}

checkout.add_capsule(
    rule = {"name": "autotools_capsule", "deps": ["@capsules/workflows"]},
    capsule = {
        "required": [
            {
                "descriptor": descriptor_base | {
                    "repo": "libtool",
                },
                "semver": "2",
                "dependency_type": "Build",
            },
            {
                "descriptor": descriptor_base | {
                    "repo": "automake",
                },
                "semver": "1",
                "dependency_type": "Build",
            },
            {
                "descriptor": descriptor_base | {
                    "repo": "autoconf",
                },
                "semver": ">=2.65",
                "dependency_type": "Build",
            },
        ],
        "scripts": ["workflows/preload.spaces.star", "workflows/autotools-capsule.spaces.star"],
        "name": "autotools-capsule",
        "version": "1.0.0",
    },
)

checkout_update_env(
    "update_env",
    paths = ["/usr/bin", "/bin"],
)
