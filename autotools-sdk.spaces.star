"""

Create a workspace using the autotools capsule.

"""

load(
    "//@sdk/star/checkout.star",
    "checkout_add_repo",
    "checkout_update_env",
    "checkout_add_which_asset"
)

checkout_add_repo(
    "@capsules/workflows",
    url = "https://github.com/work-spaces/workflows",
    rev = "50be0b119cae6b7178d2bfe404fc4d49b3c04d36",
    clone = "Default",
    is_evaluate_spaces_modules = False
)

checkout.add_capsule(
    rule = {"name": "autotools_capsule", "deps": ["@capsules/workflows"]},
    capsule = {
        "required": [
            {
                "name": "libtool",
                "semver": "2",
                "dependency_type": "Build",
            },
            {
                "name": "automake",
                "semver": "1",
                "dependency_type": "Build",
            }
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