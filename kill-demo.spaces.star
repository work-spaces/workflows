"""
Demonstrate how to use the kill rule

Run sleep5 and sleep10 - results in an error

```sh
spaces run
```

Kill sleep10 after 5 seconds

```sh
spaces run --target=kill-demo:kill-demo
```

"""


load("//@star/sdk/star/run.star", "run_add_kill_exec", "run_add_exec", "run_add_target")


run_add_exec(
    "sleep10",
    command = "/bin/sleep",
    args = ["10"],
    expect = "Failure",
    help = "Sleep for 10 seconds",
)

run_add_exec(
    "sleep5",
    command = "/bin/sleep",
    args = ["5"],
    help = "Sleep for 5 seconds",
    type = "Optional",
)

run_add_kill_exec(
    "kill-sleep10",
    target = "sleep10",
    deps = ["sleep5"],
    type = "Optional",
    expect = "Any"
)


run_add_target(
    "kill-demo",
    deps = ["kill-sleep10", "sleep10"],
    type = "Optional"
)