#!/usr/bin/python

from __future__ import print_function

import numpy as np
import h5py
import sys

# Load original RNNoise features
vdata = np.fromfile(sys.argv[1], dtype='float32');
vdata = np.reshape(vdata, (int(sys.argv[3]), int(sys.argv[4])));

# Load extended features
exFeatFile = open(sys.argv[2], 'rb')
exdata = np.load(exFeatFile)
exFeatFile.close()

# Concatenate the matrices
data = np.concatenate((vdata[:,:42], exdata, vdata[:,42:]), axis=1)

# Write feature file
h5f = h5py.File(sys.argv[5], 'w')
h5f.create_dataset('data', data=data)
h5f.close()
