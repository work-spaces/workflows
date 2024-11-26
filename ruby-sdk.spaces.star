"""Ruby Testing"""

load("//spaces-starlark-sdk/star/checkout.star", 
    "checkout_add_repo",
    "checkout_update_env")

def add_ruby(
    name,
    ruby_version,
    rbenv_rev = None):
    """
    Add ruby to your workspace using `rbenv`.

    Args:
        name: The name of the rule.
        ruby_version: The version of Ruby to install.
        rbenv_rev: The revision of rbenv to use. Default is `v1.3.0`.
    """

    effective_rbenv_version = "v1.3.0" if rbenv_rev == None else rbenv_rev

    workspace = info.get_absolute_path_to_workspace()

    checkout_add_repo(
        "rbenv",
        url = "https://github.com/rbenv/rbenv",
        rev = effective_rbenv_version,
        clone = "Shallow",
    )

    checkout_add_repo(
        "rbenv/plugins/ruby-build",
        url = "https://github.com/rbenv/ruby-build",
        rev = "v20241105",
        clone = "Shallow",
    )

    checkout_update_env(
        "{}_env_update".format(name),
        vars = { 
            "RBENV_ROOT": "{}/rbenv".format(workspace),
            "RBENV_VERSION": ruby_version
            },
        paths = ["{}/rbenv/bin".format(workspace), "{}/rbenv/shims".format(workspace)],
    )


add_ruby("ruby-sdk", "jruby-1.7.1")

checkout_update_env(
    "working_paths",
    paths = ["/usr/bin", "/bin"],
)