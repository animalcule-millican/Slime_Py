#!/usr/bin/env snakemake -s
def create_tmpdir():
    import random
    import os
    import pickle
    with open("/home/glbrc.org/millican/repos/metagenome_snakemake/etc/adj-aml.pkl", 'rb') as f:
        adj, aml = pickle.load(f)
    temp_dir_base = "/home/glbrc.org/millican/TMPDIR"    # Replace with the base path for temporary directories
    # Construct the temporary directory path
    tmpdir = os.path.join(temp_dir_base, f"{random.choice(adj)}-{random.choice(aml)}")
    # Check if the directory exists, and find a new combination if it does
    while os.path.exists(tmpdir):
        tmpdir = os.path.join(temp_dir_base, f"{random.choice(adj)}-{random.choice(aml)}")
    # Once we find a combination that does not already exist
    # Create the temporary directory
    os.makedirs(tmpdir, exist_ok=True)
    return tmpdir

rule all:
    input:
        expand("{output_directory}/database/{sample_name}.queryDB.idx", output_directory=config["output_directory"], sample_name=config["sample_name"]),
        expand("{output_directory}/database/{sample_name}.queryDB", output_directory=config["output_directory"], sample_name=config["sample_name"]),
        expand("{output_directory}/reads/{sample_name}.ecc.fq.gz", output_directory=config["output_directory"], sample_name=config["sample_name"])

rule filter_reads:
    input:
        config["sample_directory"] + "/{sample_name}.fastq.gz"
    output:
        "{output_directory}/reads/{sample_name}.filt.fq.gz"
    threads: 12
    resources:
        mem_mb = 30000
    shell:
        """
        scripts/filter_reads.sh {input} {output}
        """

rule ecc_reads:
    input:
        "{output_directory}/reads/{sample_name}.filt.fq.gz"
    output:
        "{output_directory}/reads/{sample_name}.ecc.fq.gz"
    threads: 12
    resources:
        mem_mb = 20000
    shell:
        """
        scripts/ecc_reads.sh {input} {output}
        """

rule create_DB:
    input:
        "{output_directory}/reads/{sample_name}.ecc.fq.gz"
    output:
        "{output_directory}/database/{sample_name}.queryDB"
    threads: 1
    resources:
        mem_mb = 12000
    conda:
        "slime-py"
    shell:
        """
        mmseqs createdb {input} {output}
        """

rule index_DB:
    input:
        "{output_directory}/database/{sample_name}.queryDB"
    output:
        "{output_directory}/database/{sample_name}.queryDB.idx"
    params:
        tmpdir = create_tmpdir()
    threads: 4
    resources:
        mem_mb = 36000
    conda:
        "slime-py"
    shell:
        """
        mmseqs createindex {input} {params.tmpdir}/tmp --search-type 2 --translation-table 11 --threads {threads}
        rm -rf {params.tmpdir}
        """