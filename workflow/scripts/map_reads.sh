#!/bin/bash
source ~/repos/Slime_Py/workflow/env/slimepy.env
mamba activate slime-py
source random_directory.sh

export MMSEQS_FORCE_MERGE=1
query=$1 # query sequence database
target=$2 # besthits database
maptxt=$3 # final output file from mapped reads
cpu=$4 # number of threads

mmseqs search $query $target $TMPDIR/resultsDB $TMPDIR/tmp --search-type 3 -s 7.5 --start-sens 1 --sens-steps 2 --db-load-mode 3 --threads $cpu --exact-kmer-matching 1 --max-seqs 1000000
mmseqs convertalis $query $target $TMPDIR/resultsDB $maptxt --format-mode 0 --db-load-mode 3 --format-output query,qheader,target,theader --threads $cpu

mv $target $TMPDIR
mv ${target}* $TMPDIR
trap handle_signal EXIT
trap handle_signal SIGTERM
trap handle_signal ERR
trap handle_signal SIGINT
trap handle_signal SIGQUIT
trap handle_signal SIGKILL
