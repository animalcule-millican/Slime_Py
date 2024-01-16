#!/usr/bin/env python3
from slime import slimetools, slimeking
import os
import snakemake
import argparse

def parse_args():
    parser = argparse.ArgumentParser(description="How to run the SlimePy snakemake workflow. For the detection and quantification of microbial EPS biosynthesis genes in metagenomic, metatranscriptomic, and genomic sequencing data.")
    parser.add_argument('-s', "--snakefile", help="Path to the SlimePy snakefile. Alternatively, you can set the variable SLIME_PY to the snakefile location.", default = None)
    parser.add_argument('-c', "--configfile", type=str, help="path to configfile", default = None)
    parser.add_argument('-i', "--input_directory", type=str, help="Path to directory with sequence files. Required if no config file is passed.", required=False, default = os.path.join(os.path.dirname(os.path.abspath(__file__)), "repos/Slime_Py/test"))
    parser.add_argument('-o', "--output_directory", type=str, help="Path to directory where final data files will be saved. Required if no config file is passed.", required=False, default = os.path.join(os.path.dirname(os.path.abspath(__file__)), "repos/Slime_Py/test/test_output"))
    parser.add_argument('-e', "--extension", type=str, help="File extension for input sequence files. This extension will be removed when making a list of sample names. Default: 'fastq.gz'. Important to remember if you want/need to remove additional portion of file name.", default = ".fastq.gz")
    parser.add_argument("--profile", help="Profile for running on cluster. 'slurm' or 'HTCondor'. Default is none.", action = 'store_true', default = False)
    # These arguments control specifics of running jobs, generally they do not need changing.
    parser.add_argument("--jobs", help="number of jobs to use a one time", default=400)
    parser.add_argument("--cores", help="number of cores", default=all)
    parser.add_argument("--latency_wait", help="latency_wait", default=120)
    # If using conda environments, this argument can grab conda prefix from envrionmental variables. Otherwise, the user can specify the path to conda/mamba.
    parser.add_argument("--conda_prefix", help="Path to location of Conda/Mamba", action = 'store_const', const=os.environ['MAMBA_ROOT'], default = None)
    # These arguments are used to run snakemake alternative workflows. When passed, snakemake will run perform action and then exit.
    parser.add_argument("--dryrun", help="Testing workflow with a dry run. Will not execute any rules.", action="store_true", default=False)
    parser.add_argument("--unlock", help="Unlock workflow directory. This flag will not run the workflow.", action="store_true", default=False)
    parser.add_argument("--rulegraph", help="Creating a rule graph of the snakemake workflow.", action="store_true", default=False)
    # These arguments are passed to snakemake as flags. If the argument is passed, the flag is set to the argument. If the argument is not passed, the flag is set to an empty string.
    parser.add_argument("--conda_cleanup_pkgs", help="conda_cleanup_pkgs", action="store_const", const = "['cache', 'tarballs']", default = None)
    parser.add_argument("--conda_base_path", help = "Base path to conda/mamba executable", default = None, const = os.environ['MAMBA_EXE'], action = 'store_const')
    parser.add_argument("--keep_going", help="keepgoing", action="store_true", default=False)
    parser.add_argument("--use_conda", help="use_conda", action="store_true", default=False)
    args = parser.parse_args()
    return args

def main():
    args = parse_args()
    if args.snakefile is None:
        print("None snakefile defined")
        return
    
    cluster_config = slimetools.check_for_profile(args)

    if args.configfile is None:
        configuration = slimetools.build_config(args)
    elif args.configfile is not None:
        configuration = None

    #snek = snakemake.snakemake(
    #    snakefile=args.snakefile,
    #    configfiles=args.configfile,
    #    config=configuration,
    #    workdir=configuration["working_directory"],
    #    stats=configuration["workflow_stats"],
    #    dryrun=args.dryrun,
    #    unlock=args.unlock,
    #    printrulegraph=args.rulegraph,
    #    cluster = cluster_config["cluster"],
    #    cluster_status = cluster_config["cluster-status"],
    #    cluster_cancel = cluster_config["cluster-cancel"],
    #    jobscript=cluster_config["jobscript"],
    #    use_conda = args.use_conda,
    #    keepgoing=args.keep_going,
    #    conda_prefix=args.conda_prefix,
    #    conda_cleanup_pkgs=args.conda_cleanup_pkgs,
    #    conda_base_path=args.conda_base_path,
    #    mode = 'HTCondor',
    #    local_cores=64,
    #    max_jobs_per_second=50,
    #    max_status_checks_per_second=50)

    #if snek:
    #    print("SlimePy workflow complete!")
    #    slimetools.workflow_sucess()
    #    return
    #elif not snek:
    #    print("SlimePy workflow failed.")
    #    slimetools.workflow_fail()
    #    snakemake.snakemake(
    #        snakefile=args.snakefile,
    #        configfiles=args.configfile,
    #        config=configuration,
    #        workdir=configuration["working_directory"],
    #        stats=configuration["workflow_stats"],
    #        unlock=True)
    #    return

#if __name__ == "__main__":
#    main()