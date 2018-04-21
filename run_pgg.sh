#!/bin/bash
log_dir='log/'
mkdir -p $log_dir
./gradlew build

for (( i=1; i<=$1; i++ )); do
	printf "################ Simulation#$i ################"
	log_file=$log_dir\pgg-$((i-1)).log

	# Repeat until the simulation does not present failure
	while true; do
		./gradlew -q 2>&-
		if grep -q fail $log_file; then
			rm $log_file
		else
			break
		fi
	done
	echo ' ✔'
done
