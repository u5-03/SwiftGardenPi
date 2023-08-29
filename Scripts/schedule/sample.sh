#!/bin/bash

current_date=$(date +"%Y%m%d%H%M%S")
output_file="$HOME/result/sample_${current_date}.txt"
echo "sample" >> $output_file
