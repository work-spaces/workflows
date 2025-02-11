# workflows

This repository contains sample `spaces` workflows.

This command will create a sample project for building a program using
`cmake`, `ninja` and `clang`.

```sh
git clone https://github.com/work-spaces/workflows
spaces checkout --workflow=workflows:llvm-sdk --name=llvm-workspace
cd llvm-workspace
spaces run

# To get into the ENV and run commands manually
source ./env
```
