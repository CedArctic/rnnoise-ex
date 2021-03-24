#ifndef DENOISE_H
#define DENOISE_H

#define FRAME_SIZE_SHIFT 2
#define FRAME_SIZE (120<<FRAME_SIZE_SHIFT)
#define WINDOW_SIZE (2*FRAME_SIZE)
#define FREQ_SIZE (FRAME_SIZE + 1)

#define PITCH_MIN_PERIOD 60
#define PITCH_MAX_PERIOD 768
#define PITCH_FRAME_SIZE 960
#define PITCH_BUF_SIZE (PITCH_MAX_PERIOD+PITCH_FRAME_SIZE)

#define SQUARE(x) ((x)*(x))

#define NB_BANDS 22

#define CEPS_MEM 8
#define NB_DELTA_CEPS 6

#define NB_FEATURES (NB_BANDS+3*NB_DELTA_CEPS+2)


#ifndef TRAINING
#define TRAINING 0
#endif

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "../src/kiss_fft.h"
#include "../src/common.h"
#include <math.h>
#include "rnnoise.h"
#include "../src/pitch.h"
#include "../src/arch.h"
#include "../src/rnn.h"
#include "../src/rnn_data.h"

struct DenoiseState {
  float analysis_mem[FRAME_SIZE];
  float cepstral_mem[CEPS_MEM][NB_BANDS];
  int memid;
  float synthesis_mem[FRAME_SIZE];
  float pitch_buf[PITCH_BUF_SIZE];
  float pitch_enh_buf[PITCH_BUF_SIZE];
  float last_gain;
  int last_period;
  float mem_hp_x[2];
  float lastg[NB_BANDS];
  RNNState rnn;
};

int compute_frame_features(DenoiseState *st, kiss_fft_cpx *X, kiss_fft_cpx *P,
                                  float *Ex, float *Ep, float *Exp, float *features, const float *in);

void biquad(float *y, float mem[2], const float *x, const float *b, const float *a, int N);

#endif