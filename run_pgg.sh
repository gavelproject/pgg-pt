#!/bin/bash
mkdir -p log
gradle build
for (( i=1; i<=$1; i++ )); do
	echo
	echo
	echo "################ Simulation#$i ################"
	gradle -q
done
