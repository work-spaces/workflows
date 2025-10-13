

load("//@star/sdk/star/run.star", "run_add_exec")
load("//@star/sdk/star/checkout.star", "checkout_update_env")

checkout_update_env(
    "inherited",
    system_paths = ["/usr/bin", "/bin"],
    inherited_vars = ["HOME"],
    optional_inherited_vars = ["VAR1", "VAR2"]
)

run_add_exec(
    "list",
    command = "ls",
    deps = ["//test2:list"]
)
