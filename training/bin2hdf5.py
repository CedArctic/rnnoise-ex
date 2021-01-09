#!/usr/bin/python

from __future__ import print_function

import numpy as np
import h5py
import sys

if sys.argv[4] == 'training':
    ORIGINAL_FEATURES = 87
else:
    ORIGINAL_FEATURES = 42

# Load original RNNoise features
vdata = np.fromfile(sys.argv[1], dtype='float32')
vdataY = int(vdata.size/ORIGINAL_FEATURES)
vdata = np.reshape(vdata, (vdataY, ORIGINAL_FEATURES))

# Load extended features
exFeatFile = open(sys.argv[2], 'rb')
exdata = np.load(exFeatFile)
exFeatFile.close()

# Concatenate the matrices
data = np.concatenate((vdata[:,:ORIGINAL_FEATURES], exdata, vdata[:,ORIGINAL_FEATURES:]), axis=1)

# Write feature file
h5f = h5py.File(sys.argv[3], 'w')
h5f.create_dataset('data', data=data)
h5f.close()
