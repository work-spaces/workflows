"""
Test the workflows in this repo
"""

load("//@star/sdk/star/checkout.star", "checkout_add_repo", "checkout_add_which_asset")
load("//@star/sdk/star/info.star", "info_set_minimum_version")
load("//@star/sdk/star/run.star", "run_add_exec", "RUN_TYPE_ALL")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")

info_set_minimum_version("0.14.0")
spaces_working_env()

checkout_add_repo(
    "workflows",
    url = "https://github.com/work-spaces/workflows",
    clone = "Blobless",
    rev = "main",
)

checkout_add_which_asset(
    "spaces",
    which = "spaces",
    destination = "sysroot/bin/spaces",
)

def _add_workflow_test(name, deps = [], is_run = True, target = None):
    CHECKOUT_RULE = "{}_checkout".format(name)
    run_add_exec(
        CHECKOUT_RULE,
        type = RUN_TYPE_ALL,
        command = "spaces",
        inputs = [], # run only once
        args = [
            "--hide-progress-bars",
            "--verbosity=message",
            "checkout",
            "--workflow=workflows:" + name,
            "--name=" + name,
        ],
        deps = deps,
    )
    if is_run:
        effective_target = [target] if target else []
        run_add_exec(
            name,
            command = "spaces",
            args = [
                "--hide-progress-bars",
                "--verbosity=message",
                "run",
            ] + effective_target,
            deps = [CHECKOUT_RULE],
            type = RUN_TYPE_ALL,
            working_directory = name,
            help = "Run checkout and run up to and including {}".format(name)
        )

_add_workflow_test("python-sdk")
_add_workflow_test("kill-demo", ["python-sdk"], target = "kill-demo:kill-demo")
_add_workflow_test("conan-sdk", ["kill-demo"])
_add_workflow_test("llvm-sdk", ["conan-sdk"])
_add_workflow_test("go-sdk", ["llvm-sdk"])
_add_workflow_test("node-sdk", ["go-sdk"])
_add_workflow_test("ruby-sdk", ["node-sdk"])
_add_workflow_test("packages-test", ["ruby-sdk"])
#_add_workflow_test("git-build", ["packages-test"])
_add_workflow_test("qemu-arm-build", ["packages-test"], is_run = False)
_add_workflow_test("ninja-build", ["qemu-arm-build"])
_add_workflow_test("shell-test", ["ninja-build"])
_add_workflow_test("llvm-build-16", ["shell-test"], is_run = False)
_add_workflow_test("sparse-checkout-test", ["llvm-build-16"], is_run = False)


