%RNNoise and modified
(1) Downsample noisy/cleaned samples
	Downsample_WAV.m
	(have to change folder to noisy_wav or clean_wav)
	(commented part is for folder "clean" containing original clean data)

(2) Evaluation
	EVALUATION_script.m (uses EvalPlotFun.m and EvalStatFun.m) 
	(change folder to store results - end of file)

%Classic Methods
(1) CDownsample_WAV_Noisy.m
	('_down16.wav': creates 16KHz downsampled noisy data)

(2) Denoise with Classic Methods
	CDenoiseClassicMethods.m
	(choose folder to store results using variable "technic". Also change function in for loop to change method)

(3) CDownsample_WAV_Classic.m
	('_down16_AfterDen.wav': downsampled denoised signals for PESQ and composite)

(4) CEVALUATION_script_Classic.m (uses EvalPlotFun.m and EvalStatFun.m)
	(change folder to store results - end of file and also variable "technic")

% We used Loizou's functions (comp_fwseg,comp_llr,comp_snr,composite,logmmse,pesq,wiener_as) from https://www.crcpress.com/downloads/K14513/K14513_CD_Files.zip
%  and some functions (v_readwav,v_writewav,wavread,wavwrite) for audio I/O from VOICEBOX that is under GNU Public Licence (http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html)
%  The abovementioned functions can be found on the link given.
% The function stoi in the folder is taken from http://insy.ewi.tudelft.nl/content/short-time-objective-intelligibility-measure