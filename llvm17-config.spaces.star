"""Set the version of LLVM to build and install."""

header = '"""LLVM 17 Config"""\n\n'
version = 'version = "17.0.6"\n'
sha256 = 'sha256 = "27b5c7c745ead7e9147c78471b9053d4f6fc3bed94baf45f4e8295439f564bb8"\n\n'
deploy_repo = "github.com/work-spaces/tools"

checkout.add_asset(
    rule = {"name": "llvm-config"},
    asset = {
        "content": header + version + sha256,
        "destination": "llvm-config.star",
    }
)
