#!/usr/bin/bash

#SBATCH -A p32480
#SBATCH -p short
#SBATCH -t 3:00:00
#SBATCH --mem=16G
#SBATCH --array=0-1
#SBATCH --job-name="qsm_bd2_\${SLURM_ARRAY_TASK_ID}"
#SBATCH --mail-type=ALL
#SBATCH --mail-user=akash.rathi@northwestern.edu

module purge
module load singularity/latest
echo "modules loaded" 
cd /projects/b1108/studies/BD2/scripts/QSM_libraries/STISuite_V3.0
pwd
echo "beginning preprocessing"

./master_preproc.sh $1