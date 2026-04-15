# Steps

1. Follow the steps for downloading the STISuite library from Dr. Liu at University of California, Berkeley.
https://people.eecs.berkeley.edu/~chunlei.liu/software.html

2. Place the scripts in this repository in the STISuite folder.

3. Adjust the master_preproc.sh and QSM.m scripts such that they have the proper pathnames to your raw data and output directories.

4. Adjust the parameters such that they accurately reflect your QSM sequence. This script was intended for an 8-echo sequence.
   B0 = 3;B0_dir = [0 0 1]; voxelsize = [0.70 0.70 1.3]; padsize = [12 12 12];TE = [3.01, 7.83, 12.65, 17.08, 21.12, 25.21, 29.25, 33.34];

5. Open a terminal, cd into the STISuite folder and run the following command:
   ./master_preproc.sh <subjectID>
   ex: ./master_preproc.sh 99999


# Libraries
STISuite: https://people.eecs.berkeley.edu/~chunlei.liu/software.html
FSL: https://fsl.fmrib.ox.ac.uk/fsl/docs/
