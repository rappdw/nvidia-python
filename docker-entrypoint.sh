#!/usr/bin/env bash

source /.venv/bin/activate

WORKDIR=${WORKDIR:-"/workdir"}

# install the module mounted in $WORKDIR
if [ -e $WORKDIR/setup.py ]; then
    pip install -e $WORKDIR
fi

exec "$@"
