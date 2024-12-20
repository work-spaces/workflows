




load("//@sdk/sdk/star/spaces-env.star", "spaces_working_env")
load("//@sdk/sdk/star/checkout.star", "checkout_add_repo")


checkout_add_repo(
    "stratifylabs-api",
    url = "https://github.com/StratifyLabs/API",
    rev = "main:>=1.4"
)

spaces_working_env()