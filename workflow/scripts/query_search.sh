#!/bin/bash
source ~/repos/Slime_Py/workflow/env/slimepy.env
mamba activate slime-py
source random_directory.sh

export MMSEQS_FORCE_MERGE=1

query=$1
target=$2
repDB=$4
besttxt=$3
cpu=$5

mmseqs search $query $target $TMPDIR/result $TMPDIR/tmp --start-sens 1 --sens-steps 3 -s 7 --db-load-mode 3 --merge-query 1 --threads $cpu
mmseqs filterdb $TMPDIR/result $TMPDIR/bestDB --extract-lines 1 --threads $cpu
mmseqs convertalis $query $target $TMPDIR/bestDB $besttxt --format-mode 0 --db-load-mode 3 --format-output query,qheader,qseq,target,theader,tseq,pident,evalue,tcov,qlen,tlen,qset,qsetid,tset,tsetid --threads $cpu
mmseqs createsubdb $TMPDIR/bestDB $query $repDB
mmseqs createindex $repDB --search-type 2 --translation-table 11 

trap handle_signal EXIT
trap handle_signal SIGTERM
trap handle_signal ERR
trap handle_signal SIGINT
trap handle_signal SIGQUIT
trap handle_signal SIGKILL
