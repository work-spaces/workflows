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
load("//@star/packages/star/rust.star", "rust_add")
load("//@star/packages/star/sccache.star", "sccache_add")
load("//@star/sdk/star/run.star", "run_add_exec")
load("//@star/sdk/star/ws.star", "workspace_get_absolute_path")

# Configure the top level workspace

cargo_toml_contents = """

[workspace]
resolver = "2"
members = [
    "spaces/crates/spaces",
    "spaces/crates/copy",
    "spaces/crates/graph",
    "spaces/crates/git",
    "spaces/crates/platform",
    "spaces/crates/starstd",
    "spaces/crates/changes",
    "spaces/crates/environment",
    "spaces/crates/lock",
    "spaces/crates/logger",
    "spaces/crates/suggest",
    "spaces/crates/ws",
]

[workspace.dependencies]
anyhow-source-location = { git = "https://github.com/work-spaces/anyhow-source-location", rev = "v0.1.0" }
anyhow = "1.0.95"
serde = { version = "1", features = ["derive", "rc"] }
starlark = "0.13"
state = "0.6.0"
petgraph = "0.6.5"
serde_json = "1"
glob-match = "0.2.1"
url = "2.5.2"
toml = "0.8"
serde_yaml = "0.9"
strum = { version = "0.26", features = ["derive"] }

easy-archiver = { path = "./easy-archiver", features = [
    "printer",
] }

changes.path = "spaces/crates/changes"
copy.path = "spaces/crates/copy"
environment.path = "spaces/crates/environment"
git.path = "spaces/crates/git"
graph.path = "spaces/crates/graph"
http-archive.path = "spaces/crates/http-archive"
inputs.path = "spaces/crates/inputs"
lock.path = "spaces/crates/lock"
logger.path = "spaces/crates/logger"
platform.path = "spaces/crates/platform"
printer.path = "printer"
rule.path = "spaces/crates/rule"
starstd.path = "spaces/crates/starstd"
suggest.path = "spaces/crates/suggest"
ws.path = "spaces/crates/ws"

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
            "https://github.com/work-spaces/easy-archiver": {
                "easy-archiver": {
                    "path": "./easy-archiver",
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
        "RUSTFLAGS": "--remap-path-prefix={}/=".format(workspace_get_absolute_path())
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
