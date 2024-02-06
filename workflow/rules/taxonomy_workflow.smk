#!/usr/bin/env snakemake -s
configfile: "/home/glbrc.org/millican/repos/Slime_Py/workflow/config.yml"
rule all:
    input:
        expand("{output_directory}/gather/{sample_name}_k{kmer}.{taxa}.csv", output_directory = config["output_directory"], sample_name = config["sample_name"], kmer = config["kmer"], taxa = config["taxa"]),
        expand("{output_directory}/taxonomy/{sample_name}_k{kmer}.{taxa}.csv", output_directory = config["output_directory"], sample_name = config["sample_name"], kmer = config["kmer"], taxa = config["taxa"])

rule sketch:
    input:
        "{output_directory}/reads/{sample_name}.ecc.fq.gz"
    output:
        "{output_directory}/sigs/{sample_name}.sig.gz"
    params:
        param = "k=21,k=31,k=51,scaled=1000,abund",
        sample = "{sample_name}"
    threads: 1
    resources:
        mem_mb = 10000
    conda:
        "branchwater"
    shell:
        """
        sourmash sketch dna {input} -o {output} -p {params.param} --name {params.sample}
        """

rule fastgather:
    input:
        sample = "{output_directory}/sigs/{sample_name}.sig.gz",
        ref = expand("{sourmash_directory}/reference/{{taxa}}-k{{kmer}}.zip", sourmash_directory = config["sourmash_directory"])
    output:
        "{output_directory}/gather/{sample_name}_k{kmer}.{taxa}.fastgather.csv"
    params:
        kmer = "{kmer}",
        taxa = "{taxa}",
    threads: 12
    resources:
        mem_mb = 20000
    conda:
        "branchwater"
    shell:
        """
        sourmash scripts fastgather -o {output} -t 10000 -k {params.kmer} -c {threads} {input.sample} {input.ref}
        """

rule gather:
    input:
        sample = "{output_directory}/sigs/{sample_name}.sig.gz",
        ref = expand("{sourmash_directory}/reference/{{taxa}}-k{{kmer}}.zip", sourmash_directory = config["sourmash_directory"]),
        gather = "{output_directory}/gather/{sample_name}_k{kmer}.{taxa}.fastgather.csv"
    output:
        "{output_directory}/gather/{sample_name}_k{kmer}.{taxa}.csv"
    params:
        kmer = "{kmer}",
        taxa = "{taxa}",
    threads: 12
    resources:
        mem_mb = 20000
    conda:
        "branchwater"
    shell:
        """
        sourmash gather {input.sample} {input.ref} --picklist {input.gather}:match_name:ident -o {output} -k {params.kmer} --threshold-bp 10000
        """

rule taxonomy:
    input:
        gather = "{output_directory}/gather/{sample_name}_k{kmer}.{taxa}.csv",
        lin = config["sourmash_directory"] + "/lineage/{taxa}.lineages.sqldb"
    output:
        "{output_directory}/taxonomy/{sample_name}_k{kmer}.{taxa}.csv"
    threads: 1
    resources:
        mem_mb = 20480
    conda:
        "branchwater"
    shell:
        """
        sourmash tax metagenome --gather {input.gather} --taxonomy {input.lin} --keep-full-identifiers > {output}
        """



