"""
Workflow to test the sparse-checkout feature
"""

load("//@star/sdk/star/checkout.star", "checkout_add_repo")
load("//@star/sdk/star/run.star", "run_add_exec")

checkout_add_repo(
    "StratifyOS",
    url = "https://github.com/StratifyLabs/StratifyOS",
    rev = "main",
    clone = "Blobless",
    sparse_list = ["src/", "include/"],
    sparse_mode = "Cone",
)

checkout_add_repo(
    "StratifyOS2",
    url = "https://github.com/StratifyLabs/StratifyOS",
    rev = "main",
    clone = "Blobless",
    sparse_mode = "NoCone",
    sparse_list = ["/*", "!src/", "!include/"],
    deps = ["StratifyOS"],
)

checkout_add_repo(
    "StratifyOS3",
    url = "https://github.com/StratifyLabs/StratifyOS",
    rev = "main",
    sparse_mode = "NoCone",
    sparse_list = ["/*", "!src/", "!include/"],
    deps = ["StratifyOS2"],
)

run_add_exec(
    "StratifyOS_cmake",
    command = "/bin/ls",
    args = ["StratifyOS/cmake"],
    expect = "Failure",
)

run_add_exec(
    "StratifyOS2_cmake",
    command = "/bin/ls",
    args = ["StratifyOS2/cmake"],
    expect = "Success",
)

run_add_exec(
    "StratifyOS2_src",
    command = "/bin/ls",
    args = ["StratifyOS2/src"],
    expect = "Failure",
)

run_add_exec(
    "StratifyOS3_cmake",
    command = "/bin/ls",
    args = ["StratifyOS3/cmake"],
    expect = "Success",
)

run_add_exec(
    "StratifyOS3_src",
    command = "/bin/ls",
    args = ["StratifyOS3/src"],
    expect = "Failure",
)