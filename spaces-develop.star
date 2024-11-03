"""
Spaces starlark checkout script to make changes to spaces, printer, and easy-archiver.
With VSCode integration
"""

load("sysroot-packages/star/spaces_env.star", "spaces_working_env")
load("sysroot-packages/star/rust.star", "add_rust")
load("sysroot-packages/star/sccache.star", "add_sccache")


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

checkout.add_asset(
    rule = {"name": "workspace.Cargo.toml"},
    asset = {
        "destination": "Cargo.toml",
        "content": cargo_toml_contents,
    },
)

developer_md_content = """

# Developer Notes

```sh
#this builds a faster for dev
cargo install --path=spaces/crates/spaces --root=$HOME/.local --profile=dev
cargo install --path=spaces/crates/spaces --root=$HOME/.local --profile=release
```

"""

checkout.add_asset(
    rule = {"name": "Developer_md"},
    asset = {
        "destination": "Developer.md",
        "content": developer_md_content,
    },
)

# Add spaces, printer, and easy-archiver source repositories to the workspace

printer_url = "https://github.com/work-spaces/printer-rs"
easy_archiver_url = "https://github.com/work-spaces/easy-archiver"
checkout.add_repo(
    rule = {"name": "spaces"},
    repo = {
        "url": "https://github.com/work-spaces/spaces",
        "rev": "main",
        "checkout": "Revision",
    },
)

checkout.add_repo(
    rule = {"name": "printer"},
    repo = {
        "url": printer_url,
        "rev": "main",
        "checkout": "Revision",
    },
)

checkout.add_repo(
    rule = {"name": "easy-archiver"},
    repo = {
        "url": easy_archiver_url,
        "rev": "main",
        "checkout": "Revision",
    },
)

add_rust(
    rule_name = "rust_toolchain",
    toolchain_version = "1.80",
)

add_sccache(
    rule_name = "sccache",
    sccache_version = "0.8",
)

cargo_vscode_task = {
    "type": "cargo",
    "problemMatcher": ["$rustc"],
    "group": "build",
}

checkout.update_asset(
    rule = {"name": "vscode_tasks"},
    asset = {
        "destination": ".vscode/tasks.json",
        "format": "json",
        "value": {
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
    },
)

spaces_working_env()
