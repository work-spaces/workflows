"""
Spaces starlark checkout script to make changes to spaces, printer, and easy-archiver.
With VSCode integration
"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_asset",
    "checkout_add_repo",
    "checkout_update_asset",
)
load("//@star/sdk/star/rust.star", "rust_add")
load("//@star/sdk/star/sccache.star", "sccache_add")
load("//@star/sdk/star/run.star", "run_add_exec")

# Configure the top level workspace

cargo_toml_contents = """
[workspace]
resolver = "2"
members = [
    "spaces/crates/spaces",
    "spaces/crates/graph",
    "spaces/crates/git",
    "spaces/crates/platform",
    "spaces/crates/starstd",
]

[workspace.dependencies]
anyhow-source-location = { git = "https://github.com/work-spaces/anyhow-source-location", rev = "019b7804e35a72f945b3b4b3a96520cdbaa77f70" }
anyhow = "1.0.87"
serde = { version = "1.0.130", features = ["derive"] }
starlark = "0.12.0"
state = "0.6.0"
petgraph = "0.6.5"
serde_json = "1.0.68"
glob-match = "0.2.1"
url = "2.5.2"
toml = "0.8.19"
serde_yaml = "0.9"
env_logger = "0.11.5"

easy-archiver = { path = "./easy-archiver", features = [
    "printer",
] }

printer.path = "printer"
git.path = "spaces/crates/git"
graph.path = "spaces/crates/graph"
platform.path = "spaces/crates/platform"
starstd.path = "spaces/crates/starstd"
http-archive.path = "spaces/crates/http-archive"
changes.path = "spaces/crates/changes"
environment.path = "spaces/crates/environment"
lock.path = "spaces/crates/lock"

[profile.dev]
opt-level = 3
lto = false
debug = true
strip = false
codegen-units = 16

[profile.release]
opt-level = "z"
lto = true
debug = false
panic = "abort"
strip = true
codegen-units = 1
"""

checkout_add_asset(
    "workspace.Cargo.toml",
    destination = "Cargo.toml",
    content = cargo_toml_contents,
)

developer_md_content = """

# Developer Notes

```sh
#this builds a faster for dev
cargo install --path=spaces/crates/spaces --root=$HOME/.local --profile=dev
cargo install --path=spaces/crates/spaces --root=$HOME/.local --profile=release
```

"""

checkout_add_asset(
    "Developer_md",
    destination = "Developer.md",
    content = developer_md_content,
)

# This is needed for easy-archiver to pickup the local version of printer
checkout_update_asset(
    "cargo_config",
    destination = ".cargo/config.toml",
    value = {
        "patch": {
            "https://github.com/work-spaces/printer-rs": {
                "printer": {
                    "path": "./printer",
                },
            },
        },
    },
)

# Add spaces, printer, and easy-archiver source repositories to the workspace

printer_url = "https://github.com/work-spaces/printer-rs"
easy_archiver_url = "https://github.com/work-spaces/easy-archiver"
checkout_add_repo(
    "spaces",
    url = "https://github.com/work-spaces/spaces",
    rev = "main",
)

checkout_add_repo(
    "printer",
    url = printer_url,
    rev = "main",
)

checkout_add_repo(
    "easy-archiver",
    url = easy_archiver_url,
    rev = "main",
)

rust_add(
    "rust_toolchain",
    version = "1.80",
)

sccache_add(
    "sccache",
    version = "0.8",
)

cargo_vscode_task = {
    "type": "cargo",
    "problemMatcher": ["$rustc"],
    "group": "build",
}

spaces_store = info.get_path_to_store()

task_options = {
    "env": {
        "CARGO_HOME": "{}/cargo".format(spaces_store),
        "RUSTUP_HOME": "{}/rustup".format(spaces_store),
    },
}

checkout_update_asset(
    "vscode_tasks",
    destination = ".vscode/tasks.json",
    value = {
        "options": task_options,
        "tasks": [
            cargo_vscode_task | {
                "command": "build",
                "args": ["--manifest-path=spaces/Cargo.toml"],
                "label": "build:spaces",
            },
            cargo_vscode_task | {
                "command": "install",
                "args": ["--path=spaces/crates/spaces", "--root=${userHome}/.local", "--profile=dev"],
                "label": "install_dev:spaces",
            },
            cargo_vscode_task | {
                "command": "install",
                "args": ["--path=spaces/crates/spaces", "--root=${userHome}/.local", "--profile=release"],
                "label": "install:spaces",
            },
        ],
    },
)

run_add_exec(
    "check",
    command = "cargo",
    args = ["check"],
    help = "Run cargo check on workspace",
    type = "Optional"
)

run_add_exec(
    "clippy",
    command = "cargo",
    args = ["clippy"],
    help = "Run cargo clippy on workspace",
    type = "Optional"
)

spaces_working_env()
