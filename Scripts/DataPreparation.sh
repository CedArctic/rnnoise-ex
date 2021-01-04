#!/bin/bash
# Bash script to prepare noisy audio data for analysis

echo "[$(date +%T)]: Starting..."

while IFS=, read -r file scene db; 
do 
    echo "[$(date +%T)]: Processing $file";
    # Create Directories
    mkdir -p $scene/"$db DB"/noisy_wav/
    mkdir -p $scene/"$db DB"/noisy_raw/
    mkdir -p $scene/"$db DB"/clean_raw/
    mkdir -p $scene/"$db DB"/clean_wav/
    # Categorize based on log file
    cp noisy_testset_wav/"$file.wav" $scene/"$db DB"/noisy_wav/"$file.wav"
    # Covert wave to raw
    sox $scene/"$db DB"/noisy_wav/"$file.wav" $scene/"$db DB"/noisy_raw/"$file.raw"
    # Use RNNoise to clean the audio
    rnnoise/rnnoise_demo $scene/"$db DB"/noisy_raw/"$file.raw" $scene/"$db DB"/clean_raw/"$file.raw"
    # Convert clean raw sample to wave for analysis
    sox -t raw -r 48000 -b 16 -e signed-integer -c 1 $scene/"$db DB"/clean_raw/"$file.raw" $scene/"$db DB"/clean_wav/"$file.wav"
done < log_testset.csv