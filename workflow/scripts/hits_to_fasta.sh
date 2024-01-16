#!/bin/bash
source ~/repos/Slime_Py/workflow/env/slimepy.env
mamba activate slime-py
source random_directory.sh

hits_to_fasta.py $1 $2 

trap handle_signal EXIT
trap handle_signal SIGTERM
trap handle_signal ERR
trap handle_signal SIGINT
trap handle_signal SIGQUIT
trap handle_signal SIGKILL
