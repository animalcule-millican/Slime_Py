#!/usr/bin/env snakemake -s
def create_tmpdir():
    import random
    import os
    import pickle
    with open("/home/glbrc.org/millican/repos/metagenome_snakemake/etc/adj-aml.pkl", 'rb') as f:
        adj, aml = pickle.load(f)
    # Construct the temporary directory path
    tmpdir = f"/home/glbrc.org/millican/TMPDIR/{random.choice(adj)}-{random.choice(aml)}"
    # Check if the directory exists, and find a new combination if it does
    while os.path.exists(tmpdir):
        tmpdir = f"/home/glbrc.org/millican/TMPDIR/{random.choice(adj)}-{random.choice(aml)}"
    # Once we find a combination that does not already exist
    # Create the temporary directory
    os.makedirs(tmpdir, exist_ok=True)
    return tmpdir

rule all:
    input:
        expand("{output_directory}/counts/{sample_name}.{reference_database}.query_hits.txt", output_directory=config["output_directory"], sample_name=config["sample_name"], reference_database=config["reference_database"]),
        expand("{output_directory}/fasta/{sample_name}.{reference_database}.query_hits.fna", output_directory=config["output_directory"], sample_name=config["sample_name"], reference_database=config["reference_database"])


rule search_query:
    input:
        query = "{output_directory}/database/{sample_name}.queryDB",
        index = "{output_directory}/database/{sample_name}.queryDB.idx"
    output:
        hits = "{output_directory}/counts/{sample_name}.{reference_database}.query_hits.txt",
        best = "{output_directory}/database/{sample_name}.{reference_database}.bestqueryDB"
    params:
        target = config["reference_location"] + "/{reference_database}/" + "{reference_database}_DB",
        tmpdir = create_tmpdir()
    threads: 12
    resources:
        mem_mb = 30720
    conda:
        "slime-py"
    shell:
        """
        export MMSEQS_FORCE_MERGE=1
        mmseqs search {input.query} {params.target} {params.tmpdir}/result {params.tmpdir}/tmp --start-sens 1 --sens-steps 3 -s 7 --db-load-mode 3 --merge-query 1 --threads {threads}
        mmseqs filterdb {params.tmpdir}/result {params.tmpdir}/bestDB --extract-lines 1 --threads {threads}
        mmseqs convertalis {input.query} {params.target} {params.tmpdir}/bestDB {output.hits} --format-mode 0 --db-load-mode 3 --format-output query,qheader,qseq,target,theader,tseq,pident,evalue,tcov,qlen,tlen,qset,qsetid,tset,tsetid --threads {threads}
        mmseqs createsubdb {params.tmpdir}/bestDB {input.query} {output.best}
        mmseqs createindex {output.best} --search-type 2 --translation-table 11 
        rm -rf {params.tmpdir}
        """

rule parse_hits_to_fasta:
    input:
        "{output_directory}/counts/{sample_name}.{reference_database}.query_hits.txt"
    output:
        "{output_directory}/fasta/{sample_name}.{reference_database}.query_hits.fna"
    threads: 1
    resources:
        mem_mb = 6144
    conda:
        "slime-py"
    shell:
        """
        scripts/hits_to_fasta.py {input} {output}
        """
