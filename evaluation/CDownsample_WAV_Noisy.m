clear all;

%cretes downsampled to 16KHz noisy wav files
%% FOR ALL FOLDERS EXCEPT "clean"
folders = {'bus','cafe','living','office','psquare'};
folders2 = {'2.5 DB','7.5 DB','12.5 DB','17.5 DB'};
Fresample = 16000; %final sampling frequency

for k=1:length(folders) %for every noise type folder
    for j=1:length(folders2) %for every SNR
        sAudioFolder="RNNoise2\" + folders{k} + "\ " + folders2{j} +"\noisy_wav"; %path of files
        eFiles=dir(sAudioFolder+"\*.wav"); %get all .wav files
        for i=1:length(eFiles) %for every file
            sAudioFile=fullfile(sAudioFolder,eFiles(i).name); %full path to file
            [y,Fs] = audioread(sAudioFile); %read file
            y_resamp = resample(y,Fresample,Fs); %resample at Fresample frequency
            sAudioFileOut=fullfile(sAudioFolder,[strrep(eFiles(i).name,'.wav','') '_down16.wav']); %create new filename
            audiowrite(convertStringsToChars(sAudioFileOut),y_resamp,Fresample); %store the downsampled signal
        end
    end
end