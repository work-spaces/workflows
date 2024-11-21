# workflows

This repository contains sample workflows.

This command will create a sample project for building a program using
`cmake`, `ninja` and `clang`.

```sh
git clone https://github.com/work-spaces/workflows
spaces checkout --spaces-starlark-sdk --script=workflows/llvm-sdk --name=llvm-build-test
cd llvm-build-test
spaces run

# To get in the ENV and run commands manually
source env
```
