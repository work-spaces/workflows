"""Set the version of LLVM to build and install."""

header = '"""LLVM 18 Config"""\n\n'

#version = 'version = "18.1.4"\n'
#sha256 = 'sha256 = "216fd9cc0247d7e2079fcdf2001cd6f9469b1e1ed603c3447f953ff524cdccda"\n\n'

version = 'version = "18.1.8"\n'
sha256 = 'sha256 = "f119b3d050a0de340a485804d12a357d7d28ac4d93507f488dd333c40a54f0ac"\n\n'

checkout.add_asset(
    rule = {"name": "llvm-config"},
    asset = {
        "content": header + version + sha256,
        "destination": "llvm-config.star",
    }
)
