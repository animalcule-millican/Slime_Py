#!/bin/bash
source ~/repos/Slime_Py/workflow/env/slimepy.env
mamba activate slime-py
source random_directory.sh

count_mapped_reads.py -i $1 -o $2 

if [ -f $2 ]; then
    rm $1
fi

trap handle_signal EXIT
trap handle_signal SIGTERM
trap handle_signal ERR
trap handle_signal SIGINT
trap handle_signal SIGQUIT
trap handle_signal SIGKILL
