#!/bin/bash
source ~/repos/Slime_Py/workflow/env/slimepy.env
mamba activate slime-py
source random_directory.sh
handle_signal() {
  for signal in "${signals[@]}"; do
    echo "Signal $signal received"
  done
}
mmseqs createindex $1 $TMPDIR/tmp --search-type 2 --translation-table 11 --threads $2


trap handle_signal EXIT
trap handle_signal SIGTERM
trap handle_signal ERR
trap handle_signal SIGINT
trap handle_signal SIGQUIT
trap handle_signal SIGKILL
