#!/bin/bash

docker run --rm -it --cap-add=SYS_PTRACE --security-opt="seccomp=unconfined" --security-opt="apparmor=unconfined" "$@" njfox/pwnvm-arch /bin/bash
