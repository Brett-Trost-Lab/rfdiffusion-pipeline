#!/bin/bash

### helper file to convert ProteinMPNN output into alphafold input
### REQUIRED ARGUMENT: path to .fasta file to be parsed

# parsed files will be written in same directory
fasta_dir=$(dirname $1)

echo FASTA file directory: $fasta_dir

skip_first=true # ignore original sequence

# read file line by line
while IFS= read -r line; do
	#  heck if line starts with '>' (indicates new sequence)
    if [[ $line == ">"* ]]; then
        # skip the first sequence
        if [ "$skip_first" = true ]; then
            continue
        fi
        # get sample number from the sequence identifier
        sample_num=$(echo "$line" | awk -F '[=,]' '{print $4}')
        # Create a new fasta file with the sample number as the name
        echo "$line" > $fasta_dir/sample_${sample_num}.fasta
    else
	# skip the first sequence
	if [ "$skip_first" = true ]; then
            skip_first=false
            continue
        fi
	# extract the sequence before the slash (in the case of binders, excludes the target protein)
        sequence=$(echo "$line" | cut -d'/' -f1)
	# append the sequence to the corresponding fasta file
        echo "$sequence" >> $fasta_dir/sample_${sample_num}.fasta
    fi
done < $1

echo
echo Done parsing FASTA file.
