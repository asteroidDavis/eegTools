%% test different motion
clc;
clear all;
close all;
load 'BruceData_2015_12_29_10_37_16.mat';

%% lets filter the EEG
EEGChans = (4:11);
ChanNames = {'C4', 'P4','FCZ', 'CZ', 'CPZ', 'PZ','C3','P3' };
Facq = 250;
[b,a] = butter(6,[1 35]/(Facq/2));
EEG = filtfilt(b,a,y(EEGChans,:)')';

%% analysis data 1
%tOffset = 2 seconds, eyes open & eyes closed
T1 = zeros(1,500);
EO1 = zeros(8,500);
EP1 = zeros(8,500);
EO2 = zeros(8,500);
EP2 = zeros(8,500);
for ind = 1:500
    T1(1,ind) = 0.004*ind;
    EO1(:,ind) = EEG(:,(9250+ind));
    EP1(:,ind) = EEG(:,(10500+ind));
    EO2(:,ind) = EEG(:,(12500+ind));
    EP2(:,ind) = EEG(:,(11000+ind));
end
%%
fig1.hfig = figure;
for ind = 1:8
    fig1.a(ind) = subplot(2,4,ind);
    plot(T1,[EO1(ind,:); EP1(ind,:)]);
    title(['channel we think is ' ChanNames{ind}]);
%     xlim([-1 1]);
end

%%
fig2.hfig = figure;
for ind = 1:8
    fig2.a(ind) = subplot(2,4,ind);
    plot(T1,[EO2(ind,:); EP2(ind,:)]);
    title(['channel we think is ' ChanNames{ind}]);
%     xlim([-1 1]);
end

%% analysis data 2
% T = 5 second, grind teeth,roll eyes and long-term eye closed
T2 = zeros(1,2500);
GT = zeros(8,2500);
RE = zeros(8,2500);
LTEC = zeros(8,2500);
for ind = 1:2500
    T2(1,ind) = 0.004*ind;
    GT(:,ind) = EEG(:,(15500+ind));
    RE(:,ind) = EEG(:,(19000+ind));
    LTEC(:,ind) = EEG(:,(32500+ind));
end
% plot
fig3.hfig = figure;
for ind = 1:8
    fig3.a(ind) = subplot(2,4,ind);
    plot(T2,[GT(ind,:); LTEC(ind,:)]);
    title(['channel we think is ' ChanNames{ind}]);
%     xlim([-1 1]);
end
fig4.hfig = figure;
for ind = 1:8
    fig4.a(ind) = subplot(2,4,ind);
    plot(T2,[RE(ind,:); LTEC(ind,:)]);
    title(['channel we think is ' ChanNames{ind}]);
%     xlim([-1 1]);
end