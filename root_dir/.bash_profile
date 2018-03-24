#!/usr/bin/env bash

if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

# install the module mounted in $WORKDIR (used primarily for dev or shell runs
if [ -e $WORKDIR/setup.py ]
then
    pip install -e $WORKDIR
fi

