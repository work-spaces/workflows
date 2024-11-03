"""

"""

checkout.update_env(
    rule = {"name": "update_env"},
    env = {
        "vars": {
            "PS1": '"(spaces) $PS1"',
        },
        "paths": ["/usr/bin", "/bin"],
    },
)

checkout.add_repo(
    rule = {"name": "tools/sysroot-python"},
    repo = {
        "url": "https://github.com/work-spaces/sysroot-python",
        "rev": "v3",
        "checkout": "Revision",
    },
)
