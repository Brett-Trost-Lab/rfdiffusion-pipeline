#!/bin/bash

# Launches a series of jobs for the RFdiffusion pipeline.

### REQUIRED ARGUMENTS
# $1. input file

input_file=$1

set -euo pipefail
module load python/3.11.3

echo Launching...

{
    while read -r line || [ -n "$line" ] # iterate through rows
    do
	echo
	echo $line
	eval python run_pipeline.py $line
	echo
    done
} < $input_file

echo
echo Done launching.
