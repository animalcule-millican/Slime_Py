#!/bin/bash
source ~/repos/Slime_Py/workflow/env/slimepy.env
mamba activate sourmash

sourmash sketch dna $1 -p k=21,k=31,k=51,scaled=1000,abund --output $2
