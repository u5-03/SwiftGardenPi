#!/bin/bash

current_date=$(date +"%Y%m%d%H%M%S")
output_file="$HOME/result/Result/DrainWater/output_drain_water_${current_date}.txt"
SwiftGardenPi --drainWater >> $output_file
