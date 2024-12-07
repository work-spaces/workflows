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
    rev = "383862d6b8c21ae239fff31b9d9f4385948aeb52",
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
        "scripts": ["workflows/preload.spaces.star", "workflows/autotools-capsule.spaces.star"],
        "name": "autotools-capsule",
        "version": "1.0.0",
    },
)

checkout_update_env(
    "update_env",
    paths = ["/usr/bin", "/bin"],
)
