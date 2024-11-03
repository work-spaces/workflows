"""

"""

workspace = info.get_absolute_path_to_workspace()

checkout.add_repo(
    rule = {"name": "spaces"},
    repo = {
        "url": "https://github.com/work-spaces/spaces",
        "rev": "v{}".format(version),
        "checkout": "main"
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
