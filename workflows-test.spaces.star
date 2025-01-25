"""
Test the workflows in this repo
"""

load("//@star/sdk/star/checkout.star", "checkout_add_repo", "checkout_add_which_asset")
load("//@star/sdk/star/info.star", "info_set_minimum_version")
load("//@star/sdk/star/run.star", "run_add_exec")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")

info_set_minimum_version("0.11.26")
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
            working_directory = name,
            help = "Run checkout and run up to and includeing {}".format(name)
        )

_add_workflow_test("python-sdk")
_add_workflow_test("kill-demo", ["python-sdk"], target = "kill-demo:kill-demo")
_add_workflow_test("conan-sdk", ["kill-demo"])
_add_workflow_test("llvm-sdk", ["conan-sdk"])
_add_workflow_test("go-sdk", ["llvm-sdk"])
_add_workflow_test("node-sdk", ["go-sdk"])
_add_workflow_test("ruby-sdk", ["node-sdk"])
_add_workflow_test("packages-test", ["ruby-sdk"])
_add_workflow_test("ninja-build", ["packages-test"])
_add_workflow_test("shell-test", ["ninja-build"])
_add_workflow_test("llvm-build-16", ["shell-test"], is_run = False)


