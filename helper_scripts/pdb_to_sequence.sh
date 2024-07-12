#!/bin/bash

# Extract binder sequences from ProteinMPNN PDBs. Include AF2 success from .out.txt file.

out_txt=$1
pdb_dir=$2
output_file=$3/sequences.txt

tmpfile=$(mktemp)
cat $out_txt > "${tmpfile}"

echo "" >> $tmpfile

fmt="%s\t%s\t%s\n"

printf "$fmt" sequence pae_interaction successful > $output_file

{
	read
	while read -r x x x pae_interaction x x x x x x description successful
	do
		file_name="${description%_af2pred}"

		if [ -e "${pdb_dir}/${file_name}.pdb" ]; then
			echo $file_name
			binder_seq=$(cat ${pdb_dir}/${file_name}.pdb | awk '/ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed 's/ALA/A/g;s/CYS/C/g;s/ASP/D/g;s/GLU/E/g;s/PHE/F/g;s/GLY/G/g;s/HIS/H/g;s/ILE/I/g;s/LYS/K/g;s/LEU/L/g;s/MET/M/g;s/ASN/N/g;s/PRO/P/g;s/GLN/Q/g;s/ARG/R/g;s/SER/S/g;s/THR/T/g;s/VAL/V/g;s/TRP/W/g;s/TYR/Y/g' | sed 's/ //g')
			printf "$fmt" $binder_seq $pae_interaction $successful >> $output_file
		fi
	done
} < $out_txt

