#!/usr/bin/python

from __future__ import print_function

import sys
import h5py
import numpy as np
import librosa
import soundfile as sf
import math
from tensorflow import keras
from tensorflow.keras.constraints import Constraint

# Global constants declarations
NB_BANDS = 22
FRAME_SIZE = 480
WINDOW_SIZE = FRAME_SIZE * 2
#FREQ_SIZE = FRAME_SIZE + 1
FREQ_SIZE = WINDOW_SIZE
MAX_PITCH = 768
FRAME_SIZE_SHIFT = 2
eband5ms= np.array([0,  1,  2,  3,  4,  5,  6,  7,  8, 10, 12, 14, 16, 20, 24, 28, 34, 40, 48, 60, 78, 100])

# Calculate energy for each subband
def energy(X):
  sum = [0] * NB_BANDS
  for i in range(NB_BANDS - 1):
    band_size = (eband5ms[i+1]-eband5ms[i]) << FRAME_SIZE_SHIFT
    for j in range(band_size):
      frac = j/band_size
      tmp = (X[(eband5ms[i]<<FRAME_SIZE_SHIFT) + j].real)**2+(X[(eband5ms[i]<<FRAME_SIZE_SHIFT) + j].imag)**2
      sum[i] += (1-frac)*tmp
      sum[i+1] += frac*tmp
  
  sum[0] *= 2
  sum[NB_BANDS - 1] *= 2
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

# Interpolate band gain
def interp_band_gain(bandE):
    
    g = [0] * FREQ_SIZE

    for i in range(NB_BANDS - 1):
        band_size = (eband5ms[i+1]-eband5ms[i])<<FRAME_SIZE_SHIFT
        for j in range(band_size):
            frac = j/band_size
            g[(eband5ms[i]<<FRAME_SIZE_SHIFT) + j] = (1-frac)*bandE[i] + frac*bandE[i+1]

    return g

# Pitch Filter
def pitch_filter(X, P, Ex, Ep, Exp, g):
    
    r = [0] * NB_BANDS

    resultX = []
    
    for i in range(NB_BANDS):
        if Exp[i]>g[i] :
            r[i] = 1
        else:
            r[i] = ((Exp[i])**2) *(1-(g[i])**2)/(0.001 + (g[i]**2) * (1-(Exp[i])**2))
        
        r[i] = math.sqrt(min(1, max(0, r[i])))
        r[i] *= math.sqrt(Ex[i]/(1e-8+Ep[i]))
    
    rf = interp_band_gain(r)

    for i in range(FREQ_SIZE):
        resultX.append(complex((X[i].real + rf[i]*P[i].real),(X[i].imag + rf[i]*P[i].imag)))
        # resultX[i].real += rf[i]*P[i].real
        # resultX[i].imag += rf[i]*P[i].imag
    
    newE = energy(resultX)

    norm = [(math.sqrt(Ex[i]/(1e-8+newE[i]))) for i in range(NB_BANDS)]

    normf = interp_band_gain(norm)

    for i in range(FREQ_SIZE):
        resultX[i] = complex(resultX[i].real * normf[i], resultX[i].imag * normf[i])
        # resultX[i].real *= normf[i]
        # resultX[i].imag *= normf[i]

    return resultX

# Compute band correlation
def compute_band_corr(X, P):

    sum = [0] * NB_BANDS

    for i in range(NB_BANDS - 1):
        band_size = (eband5ms[i+1]-eband5ms[i]) << FRAME_SIZE_SHIFT
        for j in range(band_size):
            frac = j / band_size
            tmp = X[(eband5ms[i]<<FRAME_SIZE_SHIFT) + j].real * P[(eband5ms[i]<<FRAME_SIZE_SHIFT) + j].real
            tmp += X[(eband5ms[i]<<FRAME_SIZE_SHIFT) + j].imag * P[(eband5ms[i]<<FRAME_SIZE_SHIFT) + j].imag
            sum[i] += (1-frac)*tmp
            sum[i+1] += frac*tmp
    
    sum[0] *= 2
    sum[NB_BANDS-1] *= 2

    return sum

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
model = keras.models.load_model(filepath='model_ex.hdf5', custom_objects={'WeightClip': WeightClip, 
'mycost':mycost, 'my_crossentropy':my_crossentropy, 'mymask':mymask, 'msse': msse, 'my_accuracy': my_accuracy})

# Load & reshape featuers data
print('Loading data...')
with h5py.File('training_ex.h5', 'r') as hf:
    all_data = hf['data'][:]
print('done.')

window_size = 2000
nb_sequences = len(all_data)//window_size
print(nb_sequences, ' sequences')
x_train = all_data[:nb_sequences*window_size, :47]
x_train = np.reshape(x_train, (nb_sequences, window_size, 47))

# Get output
output = model.predict(x_train)
vadOutput = output[1]
gainsOutput = output[0]

# Transform results data
gainsOutput = np.reshape(gainsOutput, (nb_sequences * window_size, 22))
vadOutput = np.reshape(vadOutput, (nb_sequences * window_size, 1))

# Transform input features for convenience
x_train = np.reshape(x_train, (nb_sequences * window_size, 47))

# Load audio data
y, sr = sf.read(sys.argv[1])

# Split to 20ms overlaping frames
# 960 is 20ms for 48000 sampling rate, 480 adds 10ms overlap at the beginning
inWindows = librosa.util.frame(x=y, frame_length=960, hop_length=480, axis=0)

# Calculate pitches using the input features
pitches = [round(MAX_PITCH-(x/0.01 + 300)) for x in x_train[:,40]]

# Declare gains used
finalGains = np.zeros(NB_BANDS)

# Declare output array
outData = np.zeros(len(y))

windowIndex = 0
# Fourier transform each window, apply gains and inverse FFT
for window in inWindows:

    print(windowIndex)

    # Apply vorbis window to window
    vWindow = vorbis_window(window)

    # FFT the window
    fftWindow = np.fft.fft(vWindow, n=FREQ_SIZE)

    # Energy of fftWindow
    EvWindow = energy(fftWindow)

    # Create the pitch buffer based on the last 3 windows
    pitchBuffer = []
    if windowIndex > 1:
        pitchBuffer = np.concatenate((inWindows[windowIndex - 2][(WINDOW_SIZE - MAX_PITCH):FRAME_SIZE], inWindows[windowIndex - 1][:FRAME_SIZE], window), axis=0)
    elif windowIndex == 1:
        pitchBuffer = np.concatenate((np.zeros(MAX_PITCH - FRAME_SIZE), inWindows[windowIndex - 1][:FRAME_SIZE], window), axis=0)
    elif windowIndex == 0:
        pitchBuffer = np.concatenate((np.zeros(MAX_PITCH), window), axis=0)

    # Calculate p buffer
    p = pitchBuffer[pitches[windowIndex] : pitches[windowIndex] + WINDOW_SIZE]

    # Apply vorbis window on p
    vP = vorbis_window(p)

    # FFT of vP
    fftP = np.fft.fft(vP, n=FREQ_SIZE)

    # Energy of vP
    EvP = energy(fftP)

    # Compute ExP
    ExP = compute_band_corr(fftWindow, fftP)

    # Normalize ExP
    for i in range(NB_BANDS):
        ExP[i] = ExP[i]/math.sqrt(0.001+EvWindow[i]*EvP[i])

    # Apply pitch filter
    X = pitch_filter(fftWindow, fftP, EvWindow, EvP, ExP, gainsOutput[windowIndex,:])
    # Disable pitch filter
    #X = fftWindow

    # Gain Smoothing
    alpha = 0.6
    for i in range(NB_BANDS):
        finalGains[i] = max(gainsOutput[windowIndex,i], alpha * finalGains[i])

    # Interpolate band gains
    gf = interp_band_gain(finalGains)

    # Apply gains
    for i in range(FREQ_SIZE):
        X[i] = complex((X[i].real * gf[i]), (X[i].imag * gf[i]))

    # Synthesize frames
    x = np.fft.ifft(X, n=WINDOW_SIZE)
    vx = vorbis_window(x)
    outData[(windowIndex * FRAME_SIZE):((windowIndex + 2) * FRAME_SIZE)] = np.add(outData[(windowIndex * FRAME_SIZE):((windowIndex + 2) * FRAME_SIZE)], vx)

    # Increment frame index
    windowIndex += 1

# Normalize energy
eClean = 0
for element in outData:
    eClean += element ** 2
eNoisy = 0
for element in y:
    eNoisy += element ** 2
ratio = (eNoisy / eClean)
outData = outData * ratio
outData /= max(outData)

# Write output file
sf.write(sys.argv[2], outData, sr, subtype='PCM_16')