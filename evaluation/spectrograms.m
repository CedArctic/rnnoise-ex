clear all;

%% 1

% [y1,fs] = audioread('p232_019clean.wav');
% y2 = audioread('p232_019noisy.wav');
% y3 = audioread('p232_019rnnoise.wav');
% y4 = audioread('p232_019wiener.wav');


%% 2

% [y1,fs] = audioread('p232_006clean.wav');
% y2 = audioread('p232_006noisy.wav');
% y3 = audioread('p232_006rnnoise2.5.wav');
% y4 = audioread('p232_006wiener.wav');


%% 3
% [y1,fs] = audioread('p232_019clean.wav');
% y2 = audioread('p232_019noisy.wav');
% y3 = audioread('p232_019rnnoise.wav');
% y4 = audioread('p232_019logmmse.wav');

%% 4
[y1,fs] = audioread('p232_006clean.wav');
y2 = audioread('p232_006noisy.wav');
y3 = audioread('p232_006rnnoise.wav');
y4 = audioread('p232_006logmmse.wav');

%% 5
% [y1,fs] = audioread('p232_003_clean.wav');
% y2 = audioread('p232_003_bus7.5_noisy.wav');
% y3 = audioread('p232_003_bus7.5_reference.wav');
% y4 = audioread('p232_003_bus7.5_modified.wav');


%% plot
figure
subplot(221)
spectrogram(y1,2048,1024,[],fs,'yaxis')
ax1 = gca;
ax1.YScale = 'log';
title("Clean Speech")
subplot(222)
spectrogram(y2,2048,1024,[],fs,'yaxis')
ax2 = gca;
ax2.YScale = 'log';
title("Noisy Speech")
subplot(223)
spectrogram(y3,2048,1024,[],fs,'yaxis')
ax3 = gca;
ax3.YScale = 'log';
title("Denoised Speech using RNNoise")
%title("Denoised Speech using Reference RNNoise")
subplot(224)
spectrogram(y4,2048,1024,[],fs,'yaxis')
ax4 = gca;
ax4.YScale = 'log';
%title("Denoised Speech using Wiener Filter")
title("Denoised Speech using logMMSE Method")
%title("Denoised Speech using Modified RNNoise")
% suptitle({"Output Signal Comparison"
%    "Noise Type: OFFICE, SNR: 2.5 dB"})
 suptitle({"Output Signal Comparison"
   "Noise Type: CAFE, SNR: 17.5 dB"})
%  suptitle({"Output Signal Comparison"
%     "Noise Type: BUS, SNR: 7.5 dB"})