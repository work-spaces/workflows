"""Set the version of LLVM to build and install."""

header = '"""LLVM 16 Config"""\n\n'

#version = 'version = "16.0.3"\n'
#sha256 = 'sha256 = "6591c56cec75a7c188c5f20305a9d0a7430ebe5343a922e8dae837f8d37df873"\n\n'

#version = 'version = "16.0.4"\n'
#sha256 = 'sha256 = "9de4dd11fd0cc72ee69c4c2ebab0b3cc0debe6812c284b698bd2a784842ba2cd"\n\n'

version = 'version = "16.0.6"\n'
sha256 = 'sha256 = "662f84b9266d54802e82f2b80ba24177af8032c0b5e677b1bb7466f757d1ece6"\n\n'
deploy_repo = 'deploy_repo = "github.com/work-spaces/tools"\n\n'

checkout.add_asset(
    rule = {"name": "llvm-config"},
    asset = {
        "content": header + version + sha256 + deploy_repo,
        "destination": "llvm-config.star",
    }
)
