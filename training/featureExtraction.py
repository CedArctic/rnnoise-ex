# Feature extraction example
import numpy as np
import librosa
import soundfile as sf

# Load the sample wav file with its sampling rate
#y, sr = librosa.load("processedFloatTrimmed.wav", sr=None)
#y, sr = librosa.load("6.wav", sr=None)
y, sr = sf.read('noisySpeechSamples.raw', channels=1, samplerate=48000, subtype='FLOAT')

# Split to 20ms overlaping frames
# 960 is 20ms for 48000 sampling rate, 480 adds 10ms overlap with the previous frame
frames = librosa.util.frame(x=y, frame_length=960, hop_length=480, axis=0)

# Root Mean Square
rms = librosa.feature.rms(y=y, frame_length=960, hop_length=480)

# Spectral centroid
spectral_centroid = librosa.feature.spectral_centroid(y=y, sr=sr, n_fft=960, hop_length=480)

# Spectral bandwidth
spectral_bandwidth = librosa.feature.spectral_bandwidth(y=y, sr=sr, n_fft=960, hop_length=480)

# Spectral flatness
spectral_flatness = librosa.feature.spectral_flatness(y=y, n_fft=960, hop_length=480)

# Spectral roll-off frequency
spectral_rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr, n_fft=960, hop_length=480)

# Add all features to array throwing out the last element of each feature
features = np.array([rms[0][:-1], spectral_centroid[0][:-1], spectral_bandwidth[0][:-1], spectral_flatness[0][:-1],spectral_rolloff[0][:-1]]).T

# Write results
outFile = open("extendedFeatures.bin", "wb")
np.save(outFile, features)
outFile.close()