#!/bin/bash
source ~/.bashrc

mamba env create -f $1

if [[ -f $MAMBA_ROOT/envs/slime-py/bin/mmseqs ]]; then
    wget "https://sourceforge.net/projects/bbmap/files/BBMap_39.03.tar.gz/download" -O $MAMBA_ROOT/envs/slime-py/bin/BBMap_39.03.tar.gz
    tar -xvzf $MAMBA_ROOT/envs/slime-py/bin/BBMap_39.03.tar.gz -C $MAMBA_ROOT/envs/slime-py/bin

    cat <<EOF > $MAMBA_ROOT/envs/slime-py/etc/conda/activate.d/env_vars.sh
    #!/bin/sh
    export PATH=$PATH:$MAMBA_ROOT/envs/slime-py/bin/bbmap
EOF

    cat <<EOF > $MAMBA_ROOT/envs/slime-py/etc/conda/deactivate.d/env_vars.sh
    #!/bin/sh
    export PATH=OLDPATH
    unset OLDPATH
EOF
    chmod +x $MAMBA_ROOT/envs/slime-py/etc/conda/activate.d/env_vars.sh
    chmod +x $MAMBA_ROOT/envs/slime-py/etc/conda/deactivate.d/env_vars.sh

    mamba activate slime-py
    mamba env export -f ~/repos/Slime_Py/workflow/env/slime-py-env.yml
    mamba deactivate

else
    echo "Slime-py env not created"
    exit 1
fi
