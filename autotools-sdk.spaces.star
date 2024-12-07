"""

Create a workspace using the autotools capsule.

"""

load(
    "//@sdk/star/checkout.star",
    "checkout_add_repo",
)

checkout_add_repo(
    "workflows",
    url = "https://github.com/work-spaces/workflows",
    rev = "c32df83663188147bdfedf4cbcb2f8077d9075c0",
    clone = "Default",
)

checkout.add_capsule(
    rule = {"name": "autotools_capsule"},
    capsule = {
        "required": [
            {
                "name": "libtool",
                "semver": "2",
                "dependency_type": "build",
            },
            {
                "name": "automake",
                "semver": "1",
                "dependency_type": "build",
            },
            {
                "name": "autoconf",
                "semver": "2",
                "dependency_type": "build",
            },
        ],
        "scripts": ["workflows/preload.spaces.star", "workflows/autotools-capsule.spaces.star"],
        "name": "autotools-capsule",
        "version": "1.0.0",
    },
)
