clear all;
close all;

technic = "wiener-as";
DOWNSAMPLED_BEFORE = 0;
%% Store filename of Enhanced Signals
folders = {'bus','cafe','living','office','psquare'};
folders2 = {'2.5 DB','7.5 DB','12.5 DB','17.5 DB'};

k = 0; %number of 20 contditions
data_Enh = cell(length(folders)*length(folders2),1); %filenames of enhanced
data_Enh_16 = cell(length(folders)*length(folders2),1); %filenames of enhanced 16 KHz
data_Enh_16_After = cell(length(folders)*length(folders2),1); %filenames of enhanced 16 KHz
descriptor = cell(length(folders)*length(folders2),1); %descriptors of conditions
for i=1:length(folders) %folders of noise types
    for j = 1:length(folders2) %folders of dB
        k = k+1;
        names = "RNNoise2\clean_ClassicMeth\" + technic +"\"+ folders{i} + "\" + folders2{j} +"\noisy_wav"; %folder of enhanced signals
        names = dir(names + "\p*"); %initial storage of files
        data_cell = regexpi({names.name},'p\w*_down16.wav','match'); %get only wanted filenames
        data_cell = vertcat(data_cell{:}); %discard empty records
        data_Enh_16(k) = {data_cell}; %store them in a cell array
        data_cell = regexpi({names.name},'p\d{3}_\d{3}.wav','match'); %get only wanted filenames
        data_cell = vertcat(data_cell{:}); %discard empty records
        data_Enh(k) = {data_cell}; %store them in a cell array
        data_cell = regexpi({names.name},'p\w*_down16_AfterDen.wav','match'); %get only wanted filenames
        data_cell = vertcat(data_cell{:}); %discard empty records
        data_Enh_16_After(k) = {data_cell}; %store them in a cell array
        descriptor(k) = {folders{i} + "_" + folders2{j}}; %create a descriptor for the conditions
    end
end

%% Compute Metrics
%find number of files in every folder
a = [];
for i=1:length(data_Enh)
    a(i) = length(data_Enh{i});
end

%initialization of metrics' arrays
Csig = zeros(max(a),length(data_Enh));
Cbak = zeros(max(a),length(data_Enh));
Covl = zeros(max(a),length(data_Enh));
PESQ = zeros(max(a),length(data_Enh),2);
STOI = zeros(max(a),length(data_Enh));
LLR = zeros(max(a),length(data_Enh));
fwSNRseg = zeros(max(a),length(data_Enh));
Snr_mean = zeros(max(a),length(data_Enh));
SegSNR_mean = zeros(max(a),length(data_Enh));
Pers = zeros(max(a),length(data_Enh));

%computation of metrics
for i=1:size(data_Enh,1)%for every condition (20 in total)
    files = data_Enh{i}; %filenames for enhanced
    files_16 = data_Enh_16{i};
    files_16_After = data_Enh_16_After{i};
    for j=1:length(data_Enh{i}) %for every file in the folder
        %get full path to .wav of clean and enhanced signals 
        desc = strsplit(descriptor{i},'_'); %split descriptor (type of noise & SNR)
%         name_Enh = "RNNoise2\"+ desc{1} + "\ " + desc{2} + "\clean_wav\" + files{j}; %full path to enhanced file
        name_Enh = "RNNoise2\clean_ClassicMeth\" + technic + "\"+ desc{1} + "\" + desc{2} + "\noisy_wav\" + files{j}; %full path to enhanced file
        name_Clean = "RNNoise2\clean\" + files{j}; %full path to clear file
        %16 KHz
%         name_Enh_16 = "RNNoise2\"+ desc{1} + "\ " + desc{2} + "\clean_wav\" + files_16{j}; %full path to enhanced file
        name_Enh_16 = "RNNoise2\clean_ClassicMeth\" + technic + "\"+ desc{1} + "\" + desc{2} + "\noisy_wav\" + files_16{j}; %full path to enhanced file
        name_Clean_16 = "RNNoise2\clean\" + files_16{j}; %full path to clear file
        %16 KHz After Denoising
        name_Enh_16_After = "RNNoise2\clean_ClassicMeth\" + technic+ "\" +  desc{1} + "\" + desc{2} + "\noisy_wav\" + files_16_After{j}; %full path to enhanced file
        
        if(DOWNSAMPLED_BEFORE == 1) %16KHz from the start
            %Csig/Cbak/Covl
            [Csig(j,i),Cbak(j,i),Covl(j,i)]=composite(convertStringsToChars(name_Clean_16),convertStringsToChars(name_Enh_16));
            %PESQ
            PESQ(j,i,:) = pesq(convertStringsToChars(name_Clean_16),convertStringsToChars(name_Enh_16));
            %Log-likelihood ratio (LLR)
            LLR(j,i) = comp_llr(convertStringsToChars(name_Clean_16),convertStringsToChars(name_Enh_16));
            %fwSNRseg
            fwSNRseg(j,i) = comp_fwseg(convertStringsToChars(name_Clean_16),convertStringsToChars(name_Enh_16));
            %SNR
            [Snr_mean(j,i), SegSNR_mean(j,i)]= comp_snr(convertStringsToChars(name_Clean_16),convertStringsToChars(name_Enh_16));
            %STOI
            clean_audio = audioread(name_Clean_16); %get clean audio
            [enh_audio,fs] = audioread(name_Enh_16); %get enhanced audio
            samples = min(length(clean_audio),length(enh_audio)); %find minimum number of samples between clean and enhanced
            STOI(j,i) = stoi(clean_audio(1:samples),enh_audio(1:samples),fs);
            %Pearson
            Pers(j,i) = corr(clean_audio(1:samples),enh_audio(1:samples));
        else
            %Csig/Cbak/Covl
            [Csig(j,i),Cbak(j,i),Covl(j,i)]=composite(convertStringsToChars(name_Clean_16),convertStringsToChars(name_Enh_16_After));
            %PESQ
            PESQ(j,i,:) = pesq(convertStringsToChars(name_Clean_16),convertStringsToChars(name_Enh_16_After));
            %Log-likelihood ratio (LLR)
            LLR(j,i) = comp_llr(convertStringsToChars(name_Clean),convertStringsToChars(name_Enh));
            %fwSNRseg
            fwSNRseg(j,i) = comp_fwseg(convertStringsToChars(name_Clean),convertStringsToChars(name_Enh));
            %SNR
            [Snr_mean(j,i), SegSNR_mean(j,i)]= comp_snr(convertStringsToChars(name_Clean),convertStringsToChars(name_Enh));
            %STOI
            clean_audio = audioread(name_Clean); %get clean audio
            [enh_audio,fs] = audioread(name_Enh); %get enhanced audio
            samples = min(length(clean_audio),length(enh_audio)); %find minimum number of samples between clean and enhanced
            STOI(j,i) = stoi(clean_audio(1:samples),enh_audio(1:samples),fs);
            %Pearson
            Pers(j,i) = corr(clean_audio(1:samples),enh_audio(1:samples));
        end


    end
end

% %% Statistics
% %initializaton
% Csig_mean = zeros(size(Csig,2),1);
% Cbak_mean = zeros(size(Csig,2),1);
% Covl_mean = zeros(size(Csig,2),1);
% STOI_mean = zeros(size(Csig,2),1);
% PESQ_mean = zeros(size(Csig,2),2);
% LLR_mean = zeros(size(Csig,2),1);
% fwSNRseg_mean = zeros(size(Csig,2),1);
% SNR_mean = zeros(size(Csig,2),1); %SNR_mean
% SNRseg_mean = zeros(size(Csig,2),1); %segSNR_mean
% Corr_mean = zeros(size(Csig,2),1); %Pearson correlation
% 
% 
% for i=1:size(Csig,2) %for every condition (noise type & SNR)
%     %for all metrics remove 0s (missing records) elements and then
%     %compute the mean for every condition
%     Csig_mean(i) = mean(Csig(Csig(:,i) ~= 0,i),1);
%     Cbak_mean(i) = mean(Cbak(Cbak(:,i) ~= 0,i),1);
%     Covl_mean(i) = mean(Covl(Covl(:,i) ~= 0,i),1);
%     PESQ_mean(i,1) = mean(PESQ(PESQ(:,i,1)~= 0,i,1),1); %2 for narrow- and wideband
%     PESQ_mean(i,2) = mean(PESQ(PESQ(:,i,2)~= 0,i,2),1);
%     STOI_mean(i) = mean(STOI(STOI(:,i) ~= 0,i),1);
%     LLR_mean(i) = mean(LLR(LLR(:,i) ~= 0,i),1);
%     fwSNRseg_mean(i) = mean(fwSNRseg(fwSNRseg(:,i) ~= 0,i),1);
%     SNR_mean(i) = mean(Snr_mean(Snr_mean(:,i) ~= 0,i),1);
%     SNRseg_mean(i) = mean(SegSNR_mean(SegSNR_mean(:,i) ~= 0,i),1);
%     Corr_mean(i) = mean(Pers(Pers(:,i) ~= 0,i),1);
% end

ALL_Metrics=[Csig Cbak Covl PESQ(:,:,1) PESQ(:,:,2) STOI LLR fwSNRseg Snr_mean SegSNR_mean Pers];
numberOfMetrics=11;

AllResults1_MEAN=zeros(1,11);
AllResults2_MEAN=zeros(20,11);
AllResults3_MEAN=zeros(4,11);
AllResults4_MEAN=zeros(5,11);
AllResults1_STD=zeros(1,11);
AllResults2_STD=zeros(20,11);
AllResults3_STD=zeros(4,11);
AllResults4_STD=zeros(5,11);

for i=1:numberOfMetrics
    [AllResults1_MEAN(i),AllResults2_MEAN(:,i),AllResults3_MEAN(:,i),AllResults4_MEAN(:,i),AllResults1_STD(i),AllResults2_STD(:,i),AllResults3_STD(:,i),AllResults4_STD(:,i),]=EvalPlotFun(ALL_Metrics(:,(i-1)*20+(1:20)),i);
end

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
%FigList = flip(FigList);
for iFig = 1:1:length(FigList)
FigHandle = FigList(iFig);
FigHandle.WindowState = 'maximized';
saveas(FigHandle,fullfile("resultsClassicWiener-AS48KHz",num2str(length(FigList)-iFig+1)+".png"));
end