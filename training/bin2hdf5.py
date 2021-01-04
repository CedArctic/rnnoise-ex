#!/usr/bin/python

from __future__ import print_function

import numpy as np
import h5py
import sys

# Load original RNNoise features
vdata = np.fromfile(sys.argv[1], dtype='float32');
vdata = np.reshape(data, (int(sys.argv[2]), int(sys.argv[3])));

# Load extended features


# Concatenate the matrices
data = empty([vdata.shape[0], vdata.shape[1] + exdata.shape[1]])

# Write feature file
h5f = h5py.File(sys.argv[4], 'w');
h5f.create_dataset('data', data=data)
h5f.close()
