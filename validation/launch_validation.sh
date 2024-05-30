#!/bin/bash

# Place desired input PDBs into INPUT_DIR.

set -e

work_dir=$HOME
input_dir=$work_dir/protein-binder-design/validation/inputs/

module load python/3.11.3

# Launch a separate job for each PDB

for pdb in $input_dir/*.pdb; do
    
    pdb_file_name=$(basename $pdb)
    pdb_name=$(echo $pdb_file_name | sed 's/_[^_]*$//g')
    
    echo Launching $pdb_name

    # check for hotspots file
    hotspot_file=$input_dir/hotspots/${pdb_name}_hotspots.txt

    if [ -f $hotspot_file ]; then    

        contig=$(python ./helper_scripts/get_contigs.py $pdb)
        hotspots=$(python ./helper_scripts/sample_hotspots.py $hotspot_file)
        
	# MANUAL OVERRIDE
	contig="A152-201/0 A207-214/0 A222-513/0 "

	echo Contig: $contig
        echo Hotspots: $hotspots

	sbatch ./helper_scripts/pipeline.sh $pdb $pdb_name "$contig" "$hotspots"

    else
        echo "Hotspots file not found. Please ensure ${pdb_name}_hotspots.txt is located in inputs/hotspots/ directory."
        echo Skipping $pdb_name
    fi
done

echo Done launching.
