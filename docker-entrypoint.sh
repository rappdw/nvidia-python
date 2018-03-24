#!/usr/bin/env bash

WORKDIR=${WORKDIR:-"/workdir"}

# source the correct CPU or GPU virtual environment
CPU_GPU_ENV=${CPU_GPU_ENV:-"/cpu-env"}
if [ -e $CPU_GPU_ENV ]; then
    . $CPU_GPU_ENV
fi

# fix any python script shebangs in the /usr/local/bin directory
fix-shebang

# install the module mounted in $WORKDIR
if [ -e $WORKDIR/setup.py ]; then
    pip install -e $WORKDIR
fi

exec "$@"
