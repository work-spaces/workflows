"""
Test the workflows in this repo
"""

load("//@star/sdk/star/checkout.star", "checkout_add_repo", "checkout_add_which_asset")
load("//@star/sdk/star/run.star", "run_add_exec")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")

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

def _add_workflow_test(name, deps = []):
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

    run_add_exec(
        name,
        command = "spaces",
        args = [
            "--hide-progress-bars",
            "--verbosity=message",
            "run",
        ],
        deps = [CHECKOUT_RULE],
        working_directory = name,
    )

_add_workflow_test("python-sdk")
_add_workflow_test("conan-sdk", ["python-sdk"])
_add_workflow_test("go-sdk", ["conan-sdk"])
_add_workflow_test("node-sdk", ["go-sdk"])
_add_workflow_test("ruby-sdk", ["node-sdk"])
_add_workflow_test("packages-test", ["ruby-sdk"])
_add_workflow_test("ninja-build", ["packages-test"])
_add_workflow_test("shell-test", ["ninja-build"])


