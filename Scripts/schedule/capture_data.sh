#!/bin/bash

current_date=$(date +"%Y%m%d%H%M%S")
output_file="$HOME/Result/CaptureData/output_capture_data_${current_date}.txt"
SwiftGardenPi --captureData >> $output_file
