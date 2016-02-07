%% test p300
clc;
clear all;
close all;
load 'BruceP300_2015_12_29_11_0_56.mat';

%%
% figure;
% plot(y(1,:),y(11,:));
%% some thoughts:
% Channel 11 goes non-zero whenever a target is flashed on, its value is
% the target number
%
% Channel 12 goes non-zero whenever the CHOICE target is flashed
%
% Channel 13 marks the trial number
%
%% find the onset of each trial
nTrials = max(y(13,:));
iTrialStart = find([y(13,:) nTrials]-[0 y(13,:)]>0);
%% lets filter the EEG
EEGChans = (2:9);
ChanNames = {'C4', 'P4','FCZ', 'CZ', 'CPZ', 'PZ','C3','P3' };
Facq = 250;
[b,a] = butter(6,[1 35]/(Facq/2));
% EEG = filter(b,a,y(EEGChans,:)')';
EEG = filtfilt(b,a,y(EEGChans,:)')';
%% find the indexes of all flash onsets
% skip things closer than 5 seconds to end of file
endBuffer = 5*Facq;
iMax = length(EEG(1,:))-endBuffer;
iFlashes = find(y(11,1:iMax)>0);
iChoices = find(y(12,1:iMax)>0);
iNotChoices = find((y(11,1:iMax)>0).*(y(12,1:iMax)==0));
%% now lets look at the average over -5<t<5 seconds for all 'choice' segments
offset = -5*Facq:5*Facq;
nChoice = length(iChoices);
nNotChoice = length(iNotChoices);
nTimes = length(offset);
nChans = length(EEGChans);
MeanResponse = zeros(nChans,nTimes);
MeanNotResponse = MeanResponse;
for ind = 1:nChoice
    MeanResponse = MeanResponse+EEG(:,iChoices(ind)+offset);
end
MeanResponse = MeanResponse/nChoice;
for ind = 1:nNotChoice
    MeanNotResponse = MeanNotResponse+EEG(:,iNotChoices(ind)+offset);
end
MeanNotResponse = MeanNotResponse/nNotChoice;
tOffset = offset/Facq;
%% now plot these
figure;
chan = 3;
plot(tOffset,[MeanResponse(chan,:); MeanNotResponse(chan,:)]);
%%
fig1.hfig = figure;
for ind = 1:8
    fig1.a(ind) = subplot(2,4,ind);
    plot(tOffset,[MeanResponse(ind,:); MeanNotResponse(ind,:)]);
    title(['channel we think is' ChanNames{ind}]);
    xlim([-1 1]);
end


