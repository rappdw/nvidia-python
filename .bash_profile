#!/usr/bin/env bash

# this insures that the correct env is setup
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

WORKDIR=${WORKDIR:-"/workdir"}

# install the module mounted in $WORKDIR (used primarily for dev or shell runs
if [ -e $WORKDIR ]
then
    pip install -e $WORKDIR
fi

