#!/bin/bash 

cd src
love-release -L -W -M -t Blind -r 0.2 -l 0.9.2 -a pilo .
cd ..
mv src/0.2 .
