"""
Spaces starlark script to build and deploy the spaces binary
"""

load("tools/sysroot-gh/publish.star", "add_publish_archive")

checkout.add_repo(
    rule = {"name": "tools/sysroot-gh"},
    repo = {
        "url": "https://github.com/work-spaces/sysroot-gh",
        "rev": "v2",
        "checkout": "Revision",
    },
)

checkout.add_repo(
    rule = { "name": "spaces" },
    repo = {
        "url": "https://github.com/work-spaces/spaces",
        "rev": "spaces-starlark",
        "checkout": "Revision",
    },
)

run.add_exec(
    rule = { "name": "build" },
    exec = {
        "command": "cargo",
        "working_directory": "spaces",
        "args": [
            "build",
            "--profile=release",
        ],
    },
)

spaces_toml = fs.read_toml_to_dict("spaces/Cargo.toml")
spaces_version = spaces_toml["package"]["version"]
archive_name = "spaces-v{}".format(spaces_version)

add_publish_archive(
    name = "spaces",
    input = "spaces/target/release/spaces",
    version = spaces_version,
    deploy_repo = "https://github.com/work-spaces/workflows",
    deps = ["build"]
)


