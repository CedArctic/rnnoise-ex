#!/bin/bash
# Bash script to evaluate a given set of audio files using RNNoise

# Convert all files to raw
cd noisy_testset_wav
while IFS=, read -r file scene db; 
do 
    # Print currently processed file
    echo "[$(date +%T)]: Processing $file";

    # Convert desired audio track to raw
    sox $file.wav $file.raw

    # Extract RNNoise features using the feature extractor
    ../featureExtractor/feature_extractor $file.raw $file.features.f32

    # Extract extended features
    python3.8 ../src/featureExtraction.py testing $file.wav $file.extendedFeatures.bin

    # Join feature sets using bin2hdf5
    python3.8 ../training/bin2hdf5.py $file.features.f32 $file.extendedFeatures.bin $file.fullFeatures.h5 testing
done < ../log_testset.csv

# Clean up work directory
# rm *.f32; rm *.raw; rm *.h5; rm *.bin;

cd ..

# Run RNNoise
python3.8 ./training/evaluation_batch.py noisy_testset_wav model_ex.hdf5

# Categorize files
while IFS=, read -r file scene db; 
do 
    echo "[$(date +%T)]: Processing $file";
    # Create Directories
    mkdir -p $scene/"$db DB"/noisy_wav/
    mkdir -p $scene/"$db DB"/clean_wav/
    # Categorize based on log file
    cp noisy_testset_wav/"$file.wav" $scene/"$db DB"/noisy_wav/"$file.wav"
    cp noisy_testset_wav/"$file.clean.wav" $scene/"$db DB"/clean_wav/"$file.wav"
done < log_testset.csv

rm *.clean.wav