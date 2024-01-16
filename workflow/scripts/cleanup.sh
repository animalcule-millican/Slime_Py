#!/bin/bash
source ~/.bashrc
export out=$1
export sam=$2
rm -f $out/$2.ecc.fq.gz
rm -f $out/$2*.*DB
rm -f $out/$2*.*DB*
rm -f $out/$2.sig.gz
echo "$(ls -lh $out/$2*)" > $3