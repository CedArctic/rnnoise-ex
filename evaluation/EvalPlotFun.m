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

if (metricType==1)
    ylim([0 5.2])
elseif (metricType==2)||(metricType==3)
    ylim([0 5])
elseif ((metricType==4)||(metricType==5))
    ylim([-0.5 4.5])
elseif (metricType==6)
    ylim([0 1.1])
elseif (metricType==7)
    ylim([0 2.2])
elseif (metricType==8)
    ylim([0 23.5])
elseif (metricType==9)
    ylim([0 25])
elseif (metricType==10)
    ylim([-5 16])
else
    ylim([0 1])
end


% title({'Performance in different noise conditions at various SNR levels'
%     ['Metric: ',convertStringsToChars(metricNames(metricType))]})
grid on
h=suptitle({'Performance in different noise conditions at various SNR levels'
    ['Metric: ',char(cellstr(metricNames(metricType)))]
    'Modified RNNoise'});%  --> change this part of the title manually
set(h,'FontSize',16,'FontWeight','bold')

HeightScaleFactor = 1.5;
NewHeight = h.Position(2) * HeightScaleFactor;
%h.Position(2) = h.Position(2) - (NewHeight - h.Position(4));
h.Position(2) = NewHeight;


name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name,'FontWeight', 'bold','FontSize',12);
lgd=legend('2.5dB','7.5dB','12.5dB','17.5dB', 'Location', 'northeastoutside');
title(lgd,'SNR Levels')

hold off

%saveas(h1,sprintf(convertCharsToStrings(['Figure',(3*metricType-2)])),'png');


%% 2nd Figure

h2=figure (3*metricType-1)
snrX=[2.5,7.5,12.5,17.5];

subplot(2,6,[1,2])
errorbar(snrX,out2(1:4),out6(1:4), 'LineWidth', 1.5);
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels', 'FontSize', 8)
title('Noise Profile: BUS','FontSize',9, 'FontWeight', 'bold')
grid on
set(gca,'FontWeight', 'bold','FontSize',9);

subplot(2,6,[3,4])
errorbar(snrX,out2(5:8),out6(5:8), 'LineWidth', 1.5);
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels', 'FontSize', 8)
title('Noise Profile: CAFE','FontSize',9, 'FontWeight', 'bold')
grid on
set(gca,'FontWeight', 'bold','FontSize',9);

subplot(2,6,[5,6])
errorbar(snrX,out2(9:12),out6(9:12), 'LineWidth', 1.5);
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels', 'FontSize', 8)
title('Noise Profile: LIVING','FontSize',9, 'FontWeight', 'bold')
grid on
set(gca,'FontWeight', 'bold','FontSize',9);

subplot(2,6,[8,9])
errorbar(snrX,out2(13:16),out6(13:16), 'LineWidth', 1.5);
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels', 'FontSize', 8)
title('Noise Profile: OFFICE','FontSize',9, 'FontWeight', 'bold')
grid on
set(gca,'FontWeight', 'bold','FontSize',9);

subplot(2,6,[10,11])
errorbar(snrX,out2(17:20),out6(17:20), 'LineWidth', 1.5);
xticks([2.5 7.5 12.5 17.5]) 
xlabel('SNR levels', 'FontSize', 8)
title('Noise Profile: PSQUARE','FontSize',9, 'FontWeight', 'bold')
grid on
set(gca,'FontWeight', 'bold','FontSize',9);

h=suptitle({'System Performance for Specific Noise Conditions at Different SNR Levels'
    ['Metric: ',char(cellstr(metricNames(metricType))), ' - Mofified RNNoise']
    });
set(h,'FontSize',14,'FontWeight','bold')

%% 3rd Figure

figure (3*metricType)
x=1:5;

subplot(2,2,1)
databar1=[out2(1),out2(5),out2(9),out2(13),out2(17)];
stdbar1=[out6(1),out6(5),out6(9),out6(13),out6(17)];
bar(x,databar1,'FaceColor', [0.00 0.45 0.74])
hold on
er1=errorbar(x,databar1,stdbar1);
er1.Color = [0 0 0];                            
er1.LineStyle = 'none';  
name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name,'FontWeight','bold');
hold off
title('SNR Level: 2.5dB')
grid on

subplot(2,2,2)
databar2=[out2(2),out2(6),out2(10),out2(14),out2(18)];
stdbar2=[out6(2),out6(6),out6(10),out6(14),out6(18)];
bar(x,databar2,'FaceColor', [0.85 0.33 0.10])
hold on
er2=errorbar(x,databar2,stdbar2);
er2.Color = [0 0 0];                            
er2.LineStyle = 'none';  
name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name,'FontWeight','bold');
hold off
title('SNR Level: 7.5dB')
grid on

subplot(2,2,3)
databar3=[out2(3),out2(7),out2(11),out2(15),out2(19)];
stdbar3=[out6(3),out6(7),out6(11),out6(15),out6(19)];
bar(x,databar3,'FaceColor', [0.93 0.69 0.13])
hold on
er3=errorbar(x,databar3,stdbar3);
er3.Color = [0 0 0];                            
er3.LineStyle = 'none';  
name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name,'FontWeight','bold');
hold off
title('SNR Level: 12.5dB')
grid on

subplot(2,2,4)
databar4=[out2(4),out2(8),out2(12),out2(16),out2(20)];
stdbar4=[out6(4),out6(8),out6(12),out6(16),out6(20)];
bar(x,databar4,'FaceColor', [0.49 0.18 0.56])
hold on
er4=errorbar(x,databar4,stdbar4);
er4.Color = [0 0 0];                            
er4.LineStyle = 'none';  
name={'bus'; 'cafe'; 'living'; 'office'; 'psquare'};
set(gca,'xticklabel',name,'FontWeight','bold');
hold off
title('SNR Level: 17.5dB')
grid on

h=suptitle({'System Performance at Specific SNR leves for Different Noise Profiles'
    ['Metric: ',char(cellstr(metricNames(metricType))),' - Modified RNNoise']
    });
set(h,'FontSize',14,'FontWeight','bold')
