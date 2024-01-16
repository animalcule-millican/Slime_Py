#!/bin/bash
source ~/repos/Slime_Py/workflow/env/slimepy.env
mamba activate sourmash
source random_directory.sh
tax=$SOURDB/taxonomy/$2/genbank_taxonomy.csv
sourmash tax metagenome --gather $1 --taxonomy $tax --keep-full-identifiers > $3

trap "rm -r $TMPDIR" EXIT