#!/bin/bash
source ~/repos/Slime_Py/workflow/env/slimepy.env
mamba activate sourmash
source random_directory.sh
# Use GNU parallel to run the script for each file in parallel
# Generate a unique temporary file prefix
TMP_PREFIX=$(mktemp -u)
# Run the parallel processes, each writing to a unique temporary file
find $SOURDB/signatures/$2/k${4} -name "*.sig.gz" | parallel "sourmash gather $1 {} --threshold-bp 1000 --output ${TMP_PREFIX}{#}"
# Concatenate all temporary files into the final output file
cat ${TMP_PREFIX}* > $3
# Remove the temporary files
rm ${TMP_PREFIX}*

#find $SOURDB/signatures/$2/k${4} -name "*.sig.gz" | parallel "sourmash gather $1 {} --threshold-bp 1000 --output $3"
#query=$1
#target=/home/glbrc.org/millican/ref_db/sourDB/index/$2/${2}_k${5}.sbt.zip 
#sourmash multigather $query $target --save-matches $4 --ksize $5 --output $3
 
trap handle_signal EXIT
trap handle_signal SIGTERM
trap handle_signal ERR
trap handle_signal SIGINT
trap handle_signal SIGQUIT
trap handle_signal SIGKILL
