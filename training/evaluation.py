#!/usr/bin/python

from __future__ import print_function

import h5py
import numpy as np
import librosa
import soundfile as sf
from tensorflow import keras
from tensorflow.keras.constraints import Constraint

# Calculate energy for each subband
def energy(X):
  NB_BANDS = 22
  eband5ms= np.array([0,  1,  2,  3,  4,  5,  6,  7,  8, 10, 12, 14, 16, 20, 24, 28, 34, 40, 48, 60, 78, 100])
  sum = [0] * NB_BANDS
  for i in range(21):
    band_size = 4*(eband5ms[i+1]-eband5ms[i])
    for j in range(band_size):
      frac = j/band_size
      tmp = (X[4*eband5ms[i]+j].real)**2+(X[4*eband5ms[i]+j].imag)**2
      sum[i] += (1-frac)*tmp
      sum[i+1] += frac*tmp
  
  sum[0] *= 2
  sum[22 - 1] *= 2
  Ex = [0] * NB_BANDS
  for i in range(NB_BANDS):
    Ex[i] = sum[i]

  return Ex

# Apply vorbis window
def vorbis_window(x):
    dt = np.linspace(1, 960, 960)
    win = np.sin((np.pi/2)*np.sin(np.pi*dt/960)**2)
    x = np.multiply(x,win)
    return x

# Pitch Filter
def pitch_filter(X, pitch, g):
    
    # Compute Ex (as vallin does it)
    Ex = energy(X)

# Model functions
def my_crossentropy(y_true, y_pred):
    return K.mean(2*K.abs(y_true-0.5) * K.binary_crossentropy(y_pred, y_true), axis=-1)

def mymask(y_true):
    return K.minimum(y_true+1., 1.)

def msse(y_true, y_pred):
    return K.mean(mymask(y_true) * K.square(K.sqrt(y_pred) - K.sqrt(y_true)), axis=-1)

def mycost(y_true, y_pred):
    return K.mean(mymask(y_true) * (10*K.square(K.square(K.sqrt(y_pred) - K.sqrt(y_true))) + K.square(K.sqrt(y_pred) - K.sqrt(y_true)) + 0.01*K.binary_crossentropy(y_pred, y_true)), axis=-1)

def my_accuracy(y_true, y_pred):
    return K.mean(2*K.abs(y_true-0.5) * K.equal(y_true, K.round(y_pred)), axis=-1)

# Custom object in tensorflow model
class WeightClip(Constraint):
    #Clips the weights incident to each hidden unit to be inside a range
    
    def __init__(self, c=2, **kwargs):
        self.c = c

    def __call__(self, p):
        return K.clip(p, -self.c, self.c)

    def get_config(self):
        return {'name': self.__class__.__name__,
            'c': self.c}


# Load model
model = keras.models.load_model(filepath='weights.hdf5', custom_objects={'WeightClip': WeightClip, 
'mycost':mycost, 'my_crossentropy':my_crossentropy, 'mymask':mymask, 'msse': msse, 'my_accuracy': my_accuracy})

# Load & reshape featuers data
print('Loading data...')
with h5py.File('training.h5', 'r') as hf:
    all_data = hf['data'][:]
print('done.')

window_size = 2000
nb_sequences = len(all_data)//window_size
print(nb_sequences, ' sequences')
x_train = all_data[:nb_sequences*window_size, :42]
x_train = np.reshape(x_train, (nb_sequences, window_size, 42))

# Get output
output = model.predict(x_train)
vadOutput = output[1]
gainsOutput = output[0]

# Transform results data
gainsOutput = np.reshape(gainsOutput, (nb_sequences * window_size, 22))
vadOutput = np.reshape(vadOutput, (nb_sequences * window_size, 1))

# Transform input features for convenience
x_train = np.reshape(x_train, (nb_sequences * window_size, 42))

# Load audio data
y, sr = sf.read('../src/noisySpeechSamples.raw', channels=1, samplerate=48000, subtype='FLOAT')

# Split to 20ms overlaping frames
# 960 is 20ms for 48000 sampling rate, 480 adds 5ms overlap on each side of the frame
inFrames = librosa.util.frame(x=y, frame_length=960, hop_length=480, axis=0)

# Calculate pitches using the input features
pitches = [round(768-(x/0.1 + 300)) for x in x_train[:,40]]

frameIndex = 0
# Fourier transform each frame, apply gains and inverse FFT
# for frame in frames:

#     # Apply vorbis window
#     vFrame = vorbis_window(frame)

#     # FFT the frame
#     fftFrame = np.fft.fft(vFrame)


    # Increment frame index
    frameIndex += 1


