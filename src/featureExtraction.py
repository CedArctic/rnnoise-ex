# Feature extraction example
import numpy as np
import librosa
import soundfile as sf
import sys

# Load input
if sys.argv[1] == 'training':
    # For training:
    y, sr = sf.read(sys.argv[2], channels=1, samplerate=48000, subtype='FLOAT')
else:
    # Load the sample wav file with its sampling rate
    y, sr = sf.read(sys.argv[2])

# Split to 20ms overlaping frames
# 960 is 20ms for 48000 sampling rate, 480 adds 10ms overlap with the previous frame
frames = librosa.util.frame(x=y, frame_length=960, hop_length=480, axis=0)

# Root Mean Square
#rms = librosa.feature.rms(y=y, frame_length=960, hop_length=480)

# Spectral centroid
spectral_centroid = librosa.feature.spectral_centroid(y=y, sr=sr, n_fft=960, hop_length=480)

# Spectral bandwidth
spectral_bandwidth = librosa.feature.spectral_bandwidth(y=y, sr=sr, n_fft=960, hop_length=480)

# Spectral flatness
#spectral_flatness = librosa.feature.spectral_flatness(y=y, n_fft=960, hop_length=480)

# Spectral roll-off frequency
spectral_rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr, n_fft=960, hop_length=480)

# Data normalization
spectral_centroid_std = np.std(spectral_centroid)
spectral_centroid_mean = np.mean(spectral_centroid)
spectral_centroid -= spectral_centroid_mean
spectral_centroid /= spectral_centroid_std

spectral_bandwidth_std = np.std(spectral_bandwidth)
spectral_bandwidth_mean = np.mean(spectral_bandwidth)
spectral_bandwidth -= spectral_bandwidth_mean
spectral_bandwidth /= spectral_bandwidth_std

spectral_rolloff_std = np.std(spectral_rolloff)
spectral_rolloff_mean = np.mean(spectral_rolloff)
spectral_rolloff -= spectral_rolloff_mean
spectral_rolloff /= spectral_rolloff_std

# Add all features to array throwing out the last element of each feature
features = np.array([spectral_centroid[0][:-1], spectral_bandwidth[0][:-1], spectral_rolloff[0][:-1]]).T

# Write results
outFile = open(sys.argv[3], "wb")
np.save(outFile, features)
outFile.close()