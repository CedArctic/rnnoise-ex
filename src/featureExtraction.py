# Feature extraction example
import numpy as np
import librosa
import soundfile as sf
import sys
import h5py

# Sampling rate
samplingRate = 48000

# Set up for training
if sys.argv[1] == 'training':
    # Total number of 10ms frames that will be processed
    totalFrames = int(sys.argv[4])

    # Number of samples to process per batch
    batch_size = 1000 * samplingRate

    # Βatches of samples. Division by 100 is due to the 10ms duration of each frame in totalFrames
    batches = int(totalFrames * samplingRate / (batch_size * 100))

    # Number of RNNoise frames to which each batch of samples maps to
    frames_per_batch = int(totalFrames / batches)

    # Initiallize vectors
    spectral_centroid = np.zeros(shape=(totalFrames))
    spectral_bandwidth = np.zeros(shape=(totalFrames))
    spectral_rolloff = np.zeros(shape=(totalFrames))

# Set up for testing
else:
    # Load the sample wav file with its sampling rate
    y, sr = sf.read(sys.argv[2])

    # Each frame is 10ms
    totalFrames = int(len(y) / 48000) * 100 

    batch_size = len(y)

    batches = 1

    frames_per_batch = totalFrames


# Open an h5 file for output
hf = h5py.File(sys.argv[3], 'w')

# Process batches
for batch_num in range(batches):

    print("Processing batch", batch_num, "out of", batches)

    # Load input
    if sys.argv[1] == 'training':
        # For training:
        y, sr = sf.read(sys.argv[2], channels=1, samplerate=samplingRate, subtype='PCM_16', start=batch_num*batch_size, frames=batch_size)
    else:
        # Load the sample wav file with its sampling rate
        y, sr = sf.read(sys.argv[2])

    # Split to 20ms overlaping frames
    # 960 is 20ms for 48000 sampling rate, 480 adds 10ms overlap with the previous frame
    # frames = librosa.util.frame(x=y, frame_length=960, hop_length=480, axis=0)

    # Root Mean Square
    #rms = librosa.feature.rms(y=y, frame_length=960, hop_length=480)

    # Spectral centroid
    spectral_centroid_t = librosa.feature.spectral_centroid(y=y, sr=sr, n_fft=960, hop_length=480)
    spectral_centroid_t = np.reshape(spectral_centroid_t, newshape=(-1))
    if sys.argv[1] == 'training':
        spectral_centroid[batch_num*frames_per_batch:(batch_num+1)*frames_per_batch] = spectral_centroid_t[:-1]
    else:
        spectral_centroid = spectral_centroid_t[:-1]

    # Spectral bandwidth
    spectral_bandwidth_t = librosa.feature.spectral_bandwidth(y=y, sr=sr, n_fft=960, hop_length=480)
    spectral_bandwidth_t = np.reshape(spectral_bandwidth_t, newshape=(-1))
    if sys.argv[1] == 'training':
        spectral_bandwidth[batch_num*frames_per_batch:(batch_num+1)*frames_per_batch] = spectral_bandwidth_t[:-1]
    else:
        spectral_bandwidth = spectral_bandwidth_t[:-1]

    # Spectral flatness
    #spectral_flatness = librosa.feature.spectral_flatness(y=y, n_fft=960, hop_length=480)

    # Spectral roll-off frequency
    spectral_rolloff_t = librosa.feature.spectral_rolloff(y=y, sr=sr, n_fft=960, hop_length=480)
    spectral_rolloff_t = np.reshape(spectral_rolloff_t, newshape=(-1))
    if sys.argv[1] == 'training':
        spectral_rolloff[batch_num*frames_per_batch:(batch_num+1)*frames_per_batch] = spectral_rolloff_t[:-1]
    else:
        spectral_rolloff = spectral_rolloff_t[:-1]



# Normalize and save data
if sys.argv[1] == 'training':
    spectral_centroid_std = np.std(spectral_centroid)
    spectral_centroid_mean = np.mean(spectral_centroid)
    spectral_centroid -= spectral_centroid_mean
    spectral_centroid /= spectral_centroid_std
    print('Spectral Centroid Std:', spectral_centroid_std)
    print('Spectral Centroid Mean:', spectral_centroid_mean)
else:
    spectral_centroid -= 4112.5994
    spectral_centroid /= 2842.3116
hf.create_dataset('centroid', data=spectral_centroid)

if sys.argv[1] == 'training':
    spectral_bandwidth_std = np.std(spectral_bandwidth)
    spectral_bandwidth_mean = np.mean(spectral_bandwidth)
    spectral_bandwidth -= spectral_bandwidth_mean
    spectral_bandwidth /= spectral_bandwidth_std
    print('Spectral Bandwidth Std:', spectral_bandwidth_std)
    print('Spectral Bandwidth Mean:', spectral_bandwidth_mean)
else:
    spectral_bandwidth -= 4952.0481
    spectral_bandwidth /= 1936.2998
hf.create_dataset('bandwidth', data=spectral_bandwidth)

if sys.argv[1] == 'training':
    spectral_rolloff_std = np.std(spectral_rolloff)
    spectral_rolloff_mean = np.mean(spectral_rolloff)
    spectral_rolloff -= spectral_rolloff_mean
    spectral_rolloff /= spectral_rolloff_std
    print('Spectral Rolloff Std:', spectral_rolloff_std)
    print('Spectral Rolloff Mean:', spectral_rolloff_mean)
else:
    spectral_rolloff -= 8670.3725
    spectral_rolloff /= 6298.5521
hf.create_dataset('rolloff', data=spectral_rolloff)

# Close h5
hf.close()