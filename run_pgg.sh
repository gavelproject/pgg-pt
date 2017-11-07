#!/bin/bash
mkdir -p log
for (( i=1; i<=$1; i++ )); do
	echo
	echo
	echo "################ Simulation#$i ################"
	gradle
done
