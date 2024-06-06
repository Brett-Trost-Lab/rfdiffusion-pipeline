#!/bin/bash

set -e

echo Loading module...

module load p2rank/2.4.1

echo
echo Running script...
prank predict -f $1 -o $2

echo
echo Done.
