import slimeking
import sys
import os
import yaml
import subprocess


def my_log_handler(log_dict):
    if log_dict['level'] == 'progress':
        prog_dict = log_dict['progress']
        done = prog_dict.get('done', 0)
        total = prog_dict.get('total', 0)
        if done/total == 1.0:
            print("slimepy done")
            return True
    if log_dict['level'] == 'error':
        error_dict = log_dict['error']
        if "error" in error_dict.get('msg', '').lower():
            print(log_dict.get('msg', ''))
            return False

def workflow_sucess():
    print(slimeking.finished_text)

def workflow_fail():
    print(slimeking.workflow_fail)
    print(slimeking.error_correction)
    print(slimeking.workflow_ghosts)

def check_for_profile(args):
    if args.profile:
        cluster_config = read_cluster_config(args)
        return cluster_config
    elif not args.profile:
        cluster_config = {}
        cluster_config["cluster"] = None
        cluster_config["cluster_config"] = None
        cluster_config["cluster-status"] = None
        cluster_config["cluster-cancel"] = None
        cluster_config["jobscript"] = None
        return cluster_config


def read_cluster_config(args):
    if args.profile:
        with open("/home/glbrc.org/millican/.config/snakemake/HTCondor/config.yaml", "r") as file:
            cluster_config = yaml.safe_load(file)
            cluster_config["clust_config"] = "/home/glbrc.org/millican/.config/snakemake/HTCondor/config.yaml"
    return cluster_config

def get_sample_names(input_directory, extension):
    sample_names = []
    for file in os.listdir(input_directory):
        if file.endswith(extension):
            sample = file.replace(extension, "")
            sample_names.append(sample)
    return sample_names

def build_config(args):
    sample_names = get_sample_names(args.input_directory, args.extension)
    proj_dir = os.path.abspath(os.path.join(os.path.dirname(args.snakefile), os.pardir))
    work_dir = os.path.abspath(os.path.dirname(args.snakefile))
    ref_loc = os.path.join(proj_dir, 'refdb/microbial-eps_DB')
    # Your dictionary
    config_data = {}
    config_list = []
    config_data['working_directory'] = f"{work_dir}"
    config_data['project_directory'] = f"{proj_dir}"
    config_data['sample_directory'] = os.path.abspath(args.input_directory)
    config_data['output_directory'] = os.path.abspath(args.output_directory)
    config_data['sample_name'] = sample_names
    config_data['reference_database'] = 'microbial-eps'
    config_data['latency-wait'] = args.latency_wait
    config_data['jobs'] = 500
    config_data['taxa'] = ['bacteria', 'archaea', 'plant', 'fungi', 'protozoa', 'viral']
    config_data['cores'] = 64
    config_data['workflow_stats'] = f"{os.path.join(args.output_directory, 'stats.txt')}"
    config_data['reference_location'] = f"{ref_loc}"
    config_data['outlog'] = f"{os.path.join(proj_dir, 'log')}"
    config_yml = f"{work_dir}/config.yml"
    with open(config_yml, 'w') as file:
        yaml.dump(config_data, file)
    return config_yml


def run_snakemake(config, args):
    # basic command
    cmd = ["snakemake", "-s", os.path.abspath(args.snakefile)]
    cmd += ["--configfile", config]
    cmd += ['--profile', 'HTCondor']
    if args.dryrun:
        cmd += ["--dryrun"]
    if args.unlock:
        cmd += ["--unlock"]
    # runme
    try:
        subprocess.check_call(cmd)
        return True
    except subprocess.CalledProcessError as e:
        print(f'Error in snakemake invocation: {e}', file=sys.stderr)
        return False