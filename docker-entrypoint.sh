#!/usr/bin/env bash

WORKDIR=${WORKDIR:-"/workdir"}

# install the module mounted in $WORKDIR
if [ -e $WORKDIR/setup.py ]; then
    pip install -e $WORKDIR
fi

# source the correct CPU or GPU virtual environment using NVIDIA_VISIBLE_DEVICES and CPU_GPU_ENV
# Values are documented here: https://github.com/nvidia/nvidia-container-runtime#nvidia_visible_devices
if [ -z "$NVIDIA_VISIBLE_DEVICES" ] || \
   [ "$NVIDIA_VISIBLE_DEVICES" = "void" ] || \
   [ -z "$CPU_GPU_ENV" ] || \
   [ "$CPU_GPU_ENV" == "/cpu-env" ]
then
    . /.cpu-env/bin/activate
else
    . /.gpu-env/bin/activate
fi

# fix any python script shebangs in the /usr/local/bin directory
fix-shebang

exec "$@"
