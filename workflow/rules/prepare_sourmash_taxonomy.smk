configfile: "/home/glbrc.org/millican/repos/Slime_Py/workflow/config/prepare_sourmash_taxonomy.yml"
workdir: config["working_directory"]

wildcard_constraints:
    taxa = "|".join(config["taxa"])
    database = "|".join(config["database"])

rule all:
    input:
        expand("{output_directory}/references/sketch/{taxa}.zip", taxa=config["taxa"], output_directory=config["output_directory"]),
        expand("{output_directory}/references/{taxa}_lineage.txt", taxa=config["taxa"], output_directory=config["output_directory"])

rule get_reports:
    output:
        "{output_directory}/references/reports/{taxa}_{database}_assembly_summary.txt"
    threads: 1
    resources:
        mem_mb = 1000
    shell:
        """
        wget "https://ftp.ncbi.nlm.nih.gov/genomes/{wildcards.database}/{wildcards.taxa}/assembly_summary.txt" -O {output}
        """

rule format_reports:
    input:
        gen = "{output_directory}/references/reports/{taxa}_genbank_assembly_summary.txt", 
        ref = "{output_directory}/references/reports/{taxa}_refseq_assembly_summary.txt"
    output:
        "{output_directory}/references/reports/{taxa}_assembly_summary.txt"
    threads: 1
    resources:
        mem_mb = 1000
    shell:
        """
        sed -i '1,2d' {input.gen}
        sed -i '1,2d' {input.ref}
        cat {input.gen} {input.ref} > {output}
        """

rule pickle_reports:
    input:
        "{output_directory}/references/reports/{taxa}_assembly_summary.txt"
    output:
        "{output_directory}/references/reports/{taxa}_summary.pkl"
    params:
        genome_path = "{output_directory}/references/genomes"
    threads: 1
    resources:
        mem_mb = 4000
    run:
        """
        import pickle
        info_dict = {}
        with open("{input}", 'r') as f, open("{output}", 'wb') as out:
            for line in f:
                row = line.strip().split("\t")
                accession = row[0]
                taxid = row[6]
                organism = row[7]
                if row[8] != 'na':
                    strain = row[8]
                elif row[8] == 'na':
                    strain = ''
                ftp = f"{row[19]}/{row[19].split('/')[-1]}_genomic.fna.gz"
                genome_path = f"{params.genome_path}/{row[19].split('/')[-1]}_genomic.fna.gz"
                info_dict[accession] = {'accession': accession, 'taxid': taxid, 'organism': organism, 'strain': strain, 'ftp': ftp, 'genome_path': genome_path}
            pickle.dump(info_dict, out, protocol=pickle.HIGHEST_PROTOCOL)
        """

rule get_genomes:
    input:
        "{output_directory}/references/reports/{taxa}_summary.pkl"
    output:
        "{output_directory}/references/{taxa}_genomes.txt"
    threads: 8
    resources:
        mem_mb = 6000
    run:
        """
        import urllib.request
        import os
        import pickle
        import concurrent.futures
        import time
        import random
        import glob
        import urllib.error

        url_dict = {}
        
        def download_genome(data_list):
            success = False
            while success is False:
                try:
                    urllib.request.urlretrieve(data_list[0], data_list[1])
                    time.sleep(random.uniform(0.01, 0.4))
                    success = True
                except urllib.error.HTTPError as e:
                    if e.code == 429:  # Too Many Requests
                        print("Too many requests, sleeping for a bit...")
                        time.sleep(10)
                    else:
                        success = True
            return True

        with open("{input}", 'rb') as f:
            gen_dict = pickle.load(f)
        
        for key in gen_dict.keys():
            url_dict[key] = [gen_dict[key]['ftp'], gen_dict[key]['genome_path']

        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
            executor.map(download_genome, url_dict.values())

        genome_list = glob.glob("{params.genome_path}/*.gz")
        with open("{output}", 'w') as out:
            for genome in genome_list:
                out.write(f"{genome}\n")
        """

rule get_lineage:
    input:
        "{output_directory}/references/reports/{taxa}_summary.pkl"
    output:
        "{output_directory}/references/{taxa}_lineage.txt"
    params:
        taxdmp = config["ncbi_taxonomy"]
    threads: 10
    resources:
        mem_mb = 8000
    conda:
        "branchwater"
    shell:
        """
        scripts/get_sourmash_lineage.py {input} {output} {params.taxdmp}
        """

rule sketch_references:
    input:
        "{output_directory}/references/{taxa}_genomes.txt"
    output:
        "{output_directory}/references/sketch/{taxa}.zip"
    params: 
        genome_path = "{output_directory}/references/genomes",
        csv = "{output_directory}/references/"
    threads: 24
    resources:
        mem_mb = 48000
    conda:
        "branchwater"
    shell:
        """
        scripts/sketch_references.py {params.genome_path}/{wildcards.taxa} {params.csv}/{wildcards.taxa}_sketch.csv {output} {threads}
        """
