#!/usr/bin/env spaces


"""
Parse a log
"""
script.print("Hello, world!")

log = info.parse_log_file("/Users/tgil/spaces/workflow-test/.spaces/logs/logs_20250219-07-30-30/__capsules_github.com-tukaani-project-xz-exp_cmake_build.log")

script.print("Command: {}".format(log["header"]))
script.print("Lines: {}".format(log["lines"]))