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
        expand("{output_directory}/counts/{sample_name}.{reference_database}.counted_mapped_hits.txt", output_directory=config["output_directory"], sample_name=config["sample_name"], reference_database=config["reference_database"]),
        expand("{output_directory}/counts/{sample_name}.{reference_database}.reads_mapped_hits.txt", output_directory=config["output_directory"], sample_name=config["sample_name"], reference_database=config["reference_database"])

rule map_reads:
    input:
        query = "{output_directory}/database/{sample_name}.queryDB",
        target = "{output_directory}/database/{sample_name}.{reference_database}.bestqueryDB"
    output:
        "{output_directory}/counts/{sample_name}.{reference_database}.reads_mapped_hits.txt"
    params:
        tmpdir = create_tmpdir()
    threads: 24
    resources:
        mem_mb = 30000
    conda:
        "slime-py"
    shell:
        """
        export MMSEQS_FORCE_MERGE=1
        query={input.query}
        target={input.target}
        maptxt={output}
        cpu={threads}

        mmseqs search $query $target {params.tmpdir}/resultsDB {params.tmpdir}/tmp --search-type 3 -s 7.5 --start-sens 1 --sens-steps 2 --db-load-mode 3 --threads $cpu --exact-kmer-matching 1 --max-seqs 1000000
        mmseqs convertalis $query $target {params.tmpdir}/resultsDB $maptxt --format-mode 0 --db-load-mode 3 --format-output query,qheader,target,theader --threads $cpu
        rm -rf {params.tmpdir}
        rm {input.target}
        rm {input.target}*
        """
    

rule count_mapped:
    input:
         "{output_directory}/counts/{sample_name}.{reference_database}.reads_mapped_hits.txt"
    output:
         "{output_directory}/counts/{sample_name}.{reference_database}.counted_mapped_hits.txt"
    threads: 1
    resources:
        mem_mb = 1000
    conda:
        "slime-py"
    shell:
        """
        count_mapped_reads.py -i {input} -o {output}
        """