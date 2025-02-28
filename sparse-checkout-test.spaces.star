"""
Workflow to test the sparse-checkout feature
"""

load(
    "//@star/sdk/star/checkout.star",
    "CHECKOUT_SPARSE_MODE_CONE",
    "CHECKOUT_SPARSE_MODE_NO_CONE",
    "checkout_add_repo",
)
load(
    "//@star/sdk/star/run.star",
    "RUN_EXPECT_FAILURE",
    "RUN_EXPECT_SUCCESS",
    "RUN_TYPE_ALL",
    "run_add_exec",
)

checkout_add_repo(
    "StratifyOS-default",
    url = "https://github.com/StratifyLabs/StratifyOS",
    rev = "main",
    clone = "Blobless",
)

checkout_add_repo(
    "StratifyOS-default-v4",
    url = "https://github.com/StratifyLabs/StratifyOS",
    rev = "v4.3.0",
    clone = "Blobless",
)

checkout_add_repo(
    "StratifyOS",
    url = "https://github.com/StratifyLabs/StratifyOS",
    rev = "main",
    clone = "Blobless",
    sparse_list = ["src/", "include/"],
    sparse_mode = CHECKOUT_SPARSE_MODE_CONE,
)

checkout_add_repo(
    "StratifyOS2",
    url = "https://github.com/StratifyLabs/StratifyOS",
    rev = "main",
    clone = "Blobless",
    sparse_mode = CHECKOUT_SPARSE_MODE_NO_CONE,
    sparse_list = ["/*", "!src/", "!include/"],
    deps = ["StratifyOS"],
)

checkout_add_repo(
    "StratifyOS4",
    url = "https://github.com/StratifyLabs/StratifyOS",
    rev = "v4.3.0",
    clone = "Blobless",
    sparse_mode = CHECKOUT_SPARSE_MODE_NO_CONE,
    sparse_list = ["/*", "!src/", "!include/"],
    deps = ["StratifyOS"],
)


checkout_add_repo(
    "StratifyOS3",
    url = "https://github.com/StratifyLabs/StratifyOS",
    rev = "main",
    sparse_mode = CHECKOUT_SPARSE_MODE_NO_CONE,
    sparse_list = ["/*", "!src/", "!include/"],
    deps = ["StratifyOS2"],
)

run_add_exec(
    "StratifyOS_cmake",
    command = "/bin/ls",
    args = ["StratifyOS/cmake"],
    expect = RUN_EXPECT_FAILURE,
    type = RUN_TYPE_ALL,
)

run_add_exec(
    "StratifyOS2_cmake",
    command = "/bin/ls",
    args = ["StratifyOS2/cmake"],
    expect = RUN_EXPECT_SUCCESS,
    type = RUN_TYPE_ALL,
)

run_add_exec(
    "StratifyOS2_src",
    command = "/bin/ls",
    args = ["StratifyOS2/src"],
    expect = RUN_EXPECT_FAILURE,
    type = RUN_TYPE_ALL,
)

run_add_exec(
    "StratifyOS3_cmake",
    command = "/bin/ls",
    args = ["StratifyOS3/cmake"],
    expect = RUN_EXPECT_SUCCESS,
    type = RUN_TYPE_ALL,
)

run_add_exec(
    "StratifyOS3_src",
    command = "/bin/ls",
    args = ["StratifyOS3/src"],
    expect = RUN_EXPECT_FAILURE,
    type = RUN_TYPE_ALL,
)
