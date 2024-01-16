#!/bin/bash
source ~/repos/Slime_Py/workflow/env/slimepy.env
mamba activate slime-py
mmseqs createdb $1 $2