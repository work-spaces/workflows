"""
Coreutils test checkout script
"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/packages/star/coreutils.star", "coreutils_add")


spaces_working_env(add_spaces_to_sysroot = True, inherit_terminal = True)
coreutils_add("coreutils0", "0.2.2")
