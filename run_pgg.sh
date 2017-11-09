#!/bin/bash
mkdir -p log
./gradlew build
for (( i=1; i<=$1; i++ )); do
	echo
	echo
	echo "################ Simulation#$i ################"
	./gradlew -q
done
