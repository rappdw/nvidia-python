#!/usr/bin/env bash

source /.venv/bin/activate

WORKDIR=${WORKDIR:-"/workdir"}

# if there is a python module in $WORKDIR, install it
if [ -e $WORKDIR/setup.py ]; then
    pip install -e $WORKDIR
fi

exec "$@"
