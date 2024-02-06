# Older rules, may not need anymore

rule gather:
    input:
        "{output_directory}/sigs/{sample_name}.sig.gz"
    output:
        "{output_directory}/gather/{sample_name}-{kmer}-{taxa}.gather.csv"
    params:
        taxa = "{taxa}",
        kmer = "{kmer}"
    threads: 32
    resources:
        mem_mb = 20480
    shell:
        """
        scripts/sourmash_gather.sh {input} {params.taxa} {params.kmer} {output}
        """

rule taxonomy:
    input:
        "{output_directory}/gather/{sample_name}-{kmer}-{taxa}.gather.csv"
    output:
        "{output_directory}/taxonomy/{sample_name}-{kmer}-{taxa}.taxonomy.csv"
    params:
        taxa = "{taxa}",
        kmer = "{kmer}"
    threads: 1
    resources:
        mem_mb = 20480
    shell:
        """
        scripts/sourmash_taxonomy.sh {input} {params.taxa} {output} 
        """