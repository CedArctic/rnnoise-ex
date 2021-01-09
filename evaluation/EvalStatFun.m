function [out1, out2, out3, out4]=EvalStatFun(Vmatrix,metricType,statType)
%% Instructions
% statType:
% 1 for mean
% 2 for std

% metricsType
% 1 for Csig
% 2 for Cbak
% 3 for Covl
% 4 for narrowband PESQ
% 5 for wideband PESQ
% 6 for STOI
% 7 for LLR
% 8 for fwSNRseg
% 9 for Snr_mean
% 10 for SegSNR_mean
% 11 for Pers

%% How did the system do overall? (all noise types at all SNRs)
Allvalues=Vmatrix(:);
if (statType==1)
    out1=mean(nonzeros(Allvalues));
else
    out1=std(nonzeros(Allvalues));
end

%% How did the system do for avery kind of noise for every different SNR level?

out2 = zeros(size(Vmatrix,2),1);
for i=1:size(Vmatrix,2)
    if(statType==1)
        out2(i) = mean(nonzeros(Vmatrix(:,i)));
    else
        out2(i) = std(nonzeros(Vmatrix(:,i)));
    end
end

%% How did the system do for each SNR level, taking into consideration all types of noise
%BAR??

SNR2_5=[Vmatrix(:,1)',Vmatrix(:,5)',Vmatrix(:,9)',Vmatrix(:,13)',Vmatrix(:,17)'];
SNR7_5=[Vmatrix(:,2)',Vmatrix(:,6)',Vmatrix(:,10)',Vmatrix(:,14)',Vmatrix(:,18)'];
SNR12_5=[Vmatrix(:,3)',Vmatrix(:,7)',Vmatrix(:,11)',Vmatrix(:,15)',Vmatrix(:,19)'];
SNR17_5=[Vmatrix(:,4)',Vmatrix(:,8)',Vmatrix(:,12)',Vmatrix(:,16)',Vmatrix(:,20)'];

if(statType==1)
    out3=[mean(nonzeros(SNR2_5));mean(nonzeros(SNR7_5));mean(nonzeros(SNR12_5));mean(nonzeros(SNR17_5))];
else
    out3=[std(nonzeros(SNR2_5));std(nonzeros(SNR7_5));std(nonzeros(SNR12_5));std(nonzeros(SNR17_5))];
end

%% How did the system do for each noise type, taking into consideration all SNRs
%LINEEE

if((metricType~=8)&&(metricType~=9)&&(metricType~=10))
    
    bus=[Vmatrix(:,1)',Vmatrix(:,2)',Vmatrix(:,3)',Vmatrix(:,4)'];
    cafe=[Vmatrix(:,5)',Vmatrix(:,6)',Vmatrix(:,7)',Vmatrix(:,8)'];
    living=[Vmatrix(:,9)',Vmatrix(:,10)',Vmatrix(:,11)',Vmatrix(:,12)'];
    office=[Vmatrix(:,13)',Vmatrix(:,14)',Vmatrix(:,15)',Vmatrix(:,16)'];
    psquare=[Vmatrix(:,17)',Vmatrix(:,18)',Vmatrix(:,19)',Vmatrix(:,20)'];
    
    if(statType==1)
        out4=[mean(nonzeros(bus));mean(nonzeros(cafe));mean(nonzeros(living));mean(nonzeros(office));mean(nonzeros(psquare))];
    else
        out4=[std(nonzeros(bus));std(nonzeros(cafe));std(nonzeros(living));std(nonzeros(office));std(nonzeros(psquare))];
    end
    
else
    out4=zeros(5,1);
end