#!/usr/bin/env bash

if [[ "$CPU_GPU_ENV" == "" ]]; then
    WORKDIR=${WORKDIR:-"/workdir"}
    CPU_GPU_ENV=${CPU_GPU_ENV:-"/cpu-env"}
    . $CPU_GPU_ENV
    fix-shebang
fi


