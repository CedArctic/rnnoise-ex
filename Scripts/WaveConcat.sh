#!/bin/bash
# Bash script to prepare two big audio files for training the RNNoise 

echo "[$(date +%T)]: Starting..."

# Concatenate all speech wave files into one
sox $(ls speech) speech_concatenated.wav

# Concatenate all noise wave files into one
sox $(ls noise) noise_concatenated.wav