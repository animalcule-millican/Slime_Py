"Enable python -m slime"
import os
import argparse
import slimetools

def parse_args():
    parser = argparse.ArgumentParser(description="How to run the SlimePy snakemake workflow. For the detection and quantification of microbial EPS biosynthesis genes in metagenomic, metatranscriptomic, and genomic sequencing data.")
    parser.add_argument('-s', "--snakefile", help="Path to the SlimePy snakefile. Alternatively, you can set the variable SLIME_PY to the snakefile location.", default = '')
    parser.add_argument('-c', "--configfile", type=str, help="path to configfile", default = '')
    parser.add_argument('-i', "--input_directory", type=str, help="Path to directory with sequence files. Required if no config file is passed.", required=False, default = os.path.join(os.path.dirname(os.path.abspath(__file__)), "repos/Slime_Py/test"))
    parser.add_argument('-o', "--output_directory", type=str, help="Path to directory where final data files will be saved. Required if no config file is passed.", required=False, default = os.path.join(os.path.dirname(os.path.abspath(__file__)), "repos/Slime_Py/test/test_output"))
    parser.add_argument('-e', "--extension", type=str, help="File extension for input sequence files. This extension will be removed when making a list of sample names. Default: 'fastq.gz'. Important to remember if you want/need to remove additional portion of file name.", default = ".fastq.gz")
    parser.add_argument("--profile", help="Profile for running on cluster. 'slurm' or 'HTCondor'. Default is none.", action = 'store_const', default = '', const = '/home/glbrc.org/millican/.config/snakemake/HTCondor')
    # These arguments control specifics of running jobs, generally they do not need changing.
    parser.add_argument("--jobs", help="Use at most N cluster jobs in parallel", default=400)
    parser.add_argument("--cores", help="Use at most N CPU cores in parallel", default=64)
    parser.add_argument("--latency_wait", help="Wait given seconds if an output file of a job is not present after the job finished. ", default=120)
    # If using conda environments, this argument can grab conda prefix from envrionmental variables. Otherwise, the user can specify the path to conda/mamba.
    parser.add_argument("--conda_prefix", help="Path to location of Conda/Mamba", action = 'store_const', const=os.environ['MAMBA_ROOT'], default = '')
    # These arguments are used to run snakemake alternative workflows. When passed, snakemake will run perform action and then exit.
    parser.add_argument("--dryrun", help="Testing workflow with a dry run. Will not execute any rules.", action="store_const", default=False, const = '--dry-run')
    parser.add_argument("--unlock", help="Unlock workflow directory. This flag will not run the workflow.", action="store_const", default=False, const = '--unlock')
    args = parser.parse_args()
    return args

def run():
    args = parse_args()
    if args.snakefile is None:
        print("None snakefile defined")
        return
    configuration = slimetools.build_config(args)
    slimetools.run_snakemake(configuration, args)

def main():
    run()

if __name__ == "__main__":
    main()

# cluster profile

# workflow profile

# config

# for config dict to subprocess call
# [k + "=" + v for k, v in d.items()]



# running snakemake 
# --keep-going
# --rerun-incomplete