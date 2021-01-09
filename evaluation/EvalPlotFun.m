function [out1, out2, out3, out4, out5, out6, out7, out8]=EvalPlotFun(Vmatrix,metricType)
%% Preamble
metricNames={"Csig","Cbak","Covl","narrow-band PESQ","wide-band PESQ","STOI","LLR","fwSNRseg","SNR","SegSNR","Pearson's Coefficient"}

[out1, out2, out3, out4]=EvalStatFun(Vmatrix,metricType,1);
[out5, out6, out7, out8]=EvalStatFun(Vmatrix,metricType,2);


%% 1st Figure
databar=[out2(1),out2(2),out2(3),out2(4);out2(5),out2(6),out2(7),out2(8);out2(9),out2(10),out2(11),out2(12);out2(13),out2(14),out2(15),out2(16);out2(17),out2(18),out2(19),out2(20)];
stdbar=[out6(1),out6(2),out6(3),out6(4);out6(5),out6(6),out6(7),out6(8);out6(9),out6(10),out6(11),out6(12);out6(13),out6(14),out6(15),out6(16);out6(17),out6(18),out6(19),out6(20)];

h1=figure 
hb=bar(databar);

hold on
[ngroups,nbars]=size(databar);
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, databar(:,i), stdbar(:,i), 'k', 'linestyle', 'none');
end

% title({'Performance in different noise conditions at various SNR levels'
%     ['Metric: ',convertStringsToChars(metricNames(metricType))]})

suptitle({'Performance in different noise conditions at various SNR levels'
    ['Metric: ',char(cellstr(metricNames(metricType)))]
    'Modified RNNoise (500.000)'});

name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name);
lgd=legend('2.5dB','7.5dB','12.5dB','17.5dB');
title(lgd,'SNR Levels')

hold off

%saveas(h1,sprintf(convertCharsToStrings(['Figure',(3*metricType-2)])),'png');


%% 2nd Figure

h2=figure (3*metricType-1)
snrX=[2.5,7.5,12.5,17.5];

subplot(2,6,[1,2])
errorbar(snrX,out2(1:4),out6(1:4));
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels')
title('Noise Profile: BUS')


subplot(2,6,[3,4])
errorbar(snrX,out2(5:8),out6(5:8));
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels')
title('Noise Profile: CAFE')


subplot(2,6,[5,6])
errorbar(snrX,out2(9:12),out6(9:12));
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels')
title('Noise Profile: LIVING')

subplot(2,6,[8,9])
errorbar(snrX,out2(13:16),out6(13:16));
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels')
title('Noise Profile: OFFICE')

subplot(2,6,[10,11])
errorbar(snrX,out2(17:20),out6(17:20));
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels')
title('Noise Profile: PSQUARE')

suptitle({'System Performance for Specific Noise Conditions at Different SNR Levels'
    ['Metric: ',char(cellstr(metricNames(metricType)))]
    'Modified RNNoise (500.000)'});

%% 3rd Figure

figure (3*metricType)
x=1:5;

subplot(2,2,1)
databar1=[out2(1),out2(5),out2(9),out2(13),out2(17)];
stdbar1=[out6(1),out6(5),out6(9),out6(13),out6(17)];
bar(x,databar1)
hold on
er1=errorbar(x,databar1,stdbar1);
er1.Color = [0 0 0];                            
er1.LineStyle = 'none';  
name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name);
hold off
title('SNR Level: 2.5dB')

subplot(2,2,2)
databar2=[out2(2),out2(6),out2(10),out2(14),out2(18)];
stdbar2=[out6(2),out6(6),out6(10),out6(14),out6(18)];
bar(x,databar2)
hold on
er2=errorbar(x,databar2,stdbar2);
er2.Color = [0 0 0];                            
er2.LineStyle = 'none';  
name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name);
hold off
title('SNR Level: 7.5dB')

subplot(2,2,3)
databar3=[out2(3),out2(7),out2(11),out2(15),out2(19)];
stdbar3=[out6(3),out6(7),out6(11),out6(15),out6(19)];
bar(x,databar3)
hold on
er3=errorbar(x,databar3,stdbar3);
er3.Color = [0 0 0];                            
er3.LineStyle = 'none';  
name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name);
hold off
title('SNR Level: 12.5dB')

subplot(2,2,4)
databar4=[out2(4),out2(8),out2(12),out2(16),out2(20)];
stdbar4=[out6(4),out6(8),out6(12),out6(16),out6(20)];
bar(x,databar4)
hold on
er4=errorbar(x,databar4,stdbar4);
er4.Color = [0 0 0];                            
er4.LineStyle = 'none';  
name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name);
hold off
title('SNR Level: 17.5dB')

suptitle({'System Performance at Specific SNR leves for Different Noise Profiles'
    ['Metric: ',char(cellstr(metricNames(metricType)))]
    'Modified RNNoise (500.000)'});
