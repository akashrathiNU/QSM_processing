#!/bin/bash
set -e  # stop on error

sub=$1
echo "Running subject $sub"

module load matlab
module load fsl
. ${FSLDIR}/etc/fslconf/fsl.sh

raw_dir="/projects/b1108/studies/BD2/data/raw/neuroimaging/bids/sub-${sub}/ses-1/fmap"
proc_dir="/projects/b1108/studies/BD2/data/processed/neuroimaging/STI_TIM/sub-${sub}/ses-1"
mkdir -p $proc_dir

# Check for files
echo "Checking for input files..."
ls ${raw_dir}/*.nii* || { echo "No NIfTI files found in $raw_dir"; exit 1; }

# Merge magnitude and phase
echo "Merging magnitude and phase..."
fslmerge -t ${proc_dir}/sub-${sub}_ses-1_mag_bold.nii.gz ${raw_dir}/*mag*.nii.gz
fslmerge -t ${proc_dir}/sub-${sub}_ses-1_phase_bold.nii.gz ${raw_dir}/*phase*.nii.gz

# Brain extraction
#rm ${proc_dir}/*.nii
echo "Running BET..."
#bet ${proc_dir}/sub-${sub}_ses-1_mag_bold.nii.gz ${proc_dir}/sub-${sub}_ses-1_mag_bold_brainmask.nii.gz -f 0.5 -R
bet ${raw_dir}/sub-${sub}_ses-1_task-echo_flip-16_echo-1_part-mag_bold.nii.gz ${proc_dir}/sub-${sub}_ses-1_mag_bold_brainmask.nii.gz -f 0.5 -R

find ${proc_dir} -name "*.nii.gz" -exec gunzip -f {} \;

echo "Beginning QSM"
matlab -nodisplay -nosplash -r "QSM('$1'); exit"
echo "QSM done, preproc complete"
