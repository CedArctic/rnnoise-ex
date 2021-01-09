clear all;
close all;

technic = "wiener-as";

%% Store filename of Enhanced Signals
folders = {'bus','cafe','living','office','psquare'};
folders2 = {'2.5 DB','7.5 DB','12.5 DB','17.5 DB'};

k = 0; %number of 20 contditions
data_Noisy = cell(length(folders)*length(folders2),1); %filenames of enhanced
data_Noisy_16 = cell(length(folders)*length(folders2),1); %filenames of enhanced
descriptor = cell(length(folders)*length(folders2),1); %descriptors of conditions
for i=1:length(folders) %folders of noise types
    for j = 1:length(folders2) %folders of dB
        k = k+1;
        names = "RNNoise2\" + folders{i} + "\ " + folders2{j} +"\noisy_wav"; %folder of enhanced signals
        names = dir(names + "\p*"); %initial storage of files
        data_cell = regexpi({names.name},'p\w*_down16.wav','match'); %get only wanted filenames
        data_cell = vertcat(data_cell{:}); %discard empty records
        data_Noisy_16(k) = {data_cell}; %store them in a cell array
        data_cell = regexpi({names.name},'p\d{3}_\d{3}.wav','match'); %get only wanted filenames
        data_cell = vertcat(data_cell{:}); %discard empty records
        data_Noisy(k) = {data_cell}; %store them in a cell array
        descriptor(k) = {folders{i} + "_" + folders2{j}}; %create a descriptor for the conditions
    end
end

%% Denoise
for i=1:size(data_Noisy,1)%for every condition (20 in total)
    files = data_Noisy{i}; %filenames for enhanced
    files_16 = data_Noisy_16{i};
    for j=1:length(data_Noisy{i}) %for every file in the folder
        %get full path to .wav of clean and enhanced signals 
        desc = strsplit(descriptor{i},'_'); %split descriptor (type of noise & SNR)
        name_Noisy = "RNNoise2\"+ desc{1} + "\ " + desc{2} + "\noisy_wav\" + files{j}; %full path to enhanced file
        name_Denoised = "RNNoise2\clean_ClassicMeth\" + technic + "\" + desc{1} + "\" + desc{2} + "\noisy_wav\" + files{j};
        %16 KHz
        name_Noisy_16 = "RNNoise2\"+ desc{1} + "\ " + desc{2} + "\noisy_wav\" + files_16{j}; %full path to enhanced file
        name_Denoised_16 = "RNNoise2\clean_ClassicMeth\" + technic + "\"+ desc{1} + "\" + desc{2} + "\noisy_wav\" + files_16{j};
%         logmmse(convertStringsToChars(name_Noisy),convertStringsToChars(name_Denoised));
%         logmmse(convertStringsToChars(name_Noisy_16),convertStringsToChars(name_Denoised_16));
        wiener_as(convertStringsToChars(name_Noisy),convertStringsToChars(name_Denoised));
        wiener_as(convertStringsToChars(name_Noisy_16),convertStringsToChars(name_Denoised_16));
    end
end