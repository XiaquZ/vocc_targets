#! /bin/bash
#SBATCH --job-name=cmq-velocity
#SBATCH --ntasks=1 --cpus-per-task=10 --mem-per-cpu=5000mb
#SBATCH --time=19:35:00

source $VSC_HOME/.bashrc

conda activate VoCC_R_new

cd $VSC_DATA/vocc_targets/
export OMP_NUM_THREADS=1

Rscript targets_run_cmq.R
