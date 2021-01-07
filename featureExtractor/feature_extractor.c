/* Copyright (c) 2018 Gregor Richards
 * Copyright (c) 2017 Mozilla */
/*
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "rnnoise.h"
#include "../config.h"
#include "../src/kiss_fft.h"
#include "../src/common.h"
#include "../src/pitch.h"
#include "../src/arch.h"
#include "../src/rnn.h"
#include "../src/rnn_data.h"
#include "../src/denoise.h"


#define NB_BANDS 22
#define NB_DELTA_CEPS 6
#define NB_FEATURES (NB_BANDS+3*NB_DELTA_CEPS+2)
#define FRAME_SIZE_SHIFT 2
#define FRAME_SIZE (120<<FRAME_SIZE_SHIFT)
#define WINDOW_SIZE (2*FRAME_SIZE)
#define FREQ_SIZE (FRAME_SIZE + 1)

void feature_extraction(DenoiseState *st, float *out, const float *in, float* features) {
  kiss_fft_cpx X[FREQ_SIZE];
  kiss_fft_cpx P[WINDOW_SIZE];
  float x[FRAME_SIZE];
  float Ex[NB_BANDS], Ep[NB_BANDS];
  float Exp[NB_BANDS];
  
  static const float a_hp[2] = {-1.99599, 0.99600};
  static const float b_hp[2] = {-2, 1};

  biquad(x, st->mem_hp_x, in, b_hp, a_hp, FRAME_SIZE);

  compute_frame_features(st, X, P, Ex, Ep, Exp, features, x);

  return;
}

int main(int argc, char **argv) {

  float x[FRAME_SIZE];
  FILE *f1, *fout;

  float features[NB_FEATURES];

  // Create and allocate state
  DenoiseState *st;
  st = rnnoise_create(NULL);

  // Invalid input error message
  if (argc!=3) {
    fprintf(stderr, "usage: %s <noisy speech.raw> <features output.f32>\n", argv[0]);
    return 1;
  }

  // Open file I/O streams
  f1 = fopen(argv[1], "rb");
  fout = fopen(argv[2], "wb");

  while (1) {

    // Allocate temporary space for the current frame and load it to memory
    short tmp[FRAME_SIZE];
    fread(tmp, sizeof(short), FRAME_SIZE, f1);
    
    // Check if we reached end of file
    if (feof(f1)) break;
    
    // Copy frame to x[]
    for (int i=0;i<FRAME_SIZE;i++){
      x[i] = tmp[i];
    }
    
    // Process frame with RNNoise
    // rnnoise_process_frame(st, x, x);
    feature_extraction(st, x, x, features);

    // Write out features
    fwrite(features, sizeof(float), NB_FEATURES, fout);
  }

  // Destructors & File I/O close
  rnnoise_destroy(st);
  fclose(f1);
  fclose(fout);
  return 0;
}