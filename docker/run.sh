#!/bin/bash

docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined "$@" njfox/pwnvm-arch /bin/bash
