#!/bin/bash
source /home/glbrc.org/millican/.bashrc
slimepy=/home/glbrc.org/millican/repos/Slime_Py/Slime.py
slime_snek=/home/glbrc.org/millican/repos/Slime_Py/workflow/Snakefile
$slimepy -s $slime_snek -i $HOME/metagenome/lamps/data/reads/raw -o $HOME/repos/Slime_Py/slime_out -e .fastq.gz --profile