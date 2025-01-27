%%
%Anlysis of P300 data

%%
%Setup

facq = 250;
dt = 1/facq;
%The contents of each channel 
channels = {'time', 'P3', 'Pz', 'P4', 'CPz', 'PO7', 'POz', 'PO8','Oz',...
    'sampleNo', 'trigger', 'choice', 'trialNo'};
dataChannels = 2:9;

%BAD DATA
% exp1RawData = load('Nata_P300_Run2_2016_2_25_14_29_25.mat');
% exp2RawData = load('Nata_P300_Run3_2016_2_25_14_52_49.mat');

% %load the first trial
exp1RawData = load('Genius_P300_Run1_2016_3_3_13_35_31.mat');
% %load the second trial with modified characteristics
exp2RawData = load('Genius_P300_Run2_2016_3_3_14_34_45.mat');

dataSrc = str2double(inputdlg('Experiment 1 or 2?'));
if(dataSrc == 1)
    rawData = exp1RawData.y;
elseif(dataSrc == 2)
    rawData = exp2RawData.y;
else
    error('Not a valid experiment number');
end
%%
%extract the indices of each time the correct choice flashed
choiceIndex = find(rawData(find(strcmp(channels, 'choice')), :) == 1);
%extract the index of each time a choice flashed
nChoiceIndex = find(rawData(find(strcmp(channels, 'trigger')), :) ~= 0);

%remove indexes in flashIndex where choice is also set
index = 1;
for electrodeIndex = ismember(nChoiceIndex, choiceIndex)
    if(electrodeIndex == 1)
        nChoiceIndex(index) = [];
    else
        index = index +1;
    end
end
nChoiceIndex = nChoiceIndex(~arrayfun(@isempty, nChoiceIndex));
%%
%plot 5 (5-10) seconds of each channel
figure;
channelCount = length(rawData(:,1));

for chIndex = 1:channelCount
    data = rawData(chIndex, :);
    %plot the stuff in a figure
    subplot(round(channelCount/2), 2, chIndex);
    plot(5:dt:10, data(5/dt:10/dt));
    try
        title(channels{chIndex});
    catch ME
        title('Not named');
    end
end

%%
%filters the data with a 1-30Hz buttersworth bandpass filter
filteredData = zeros(length(dataChannels), length(rawData(dataChannels(1),:)));

[bDesign, aDesign] = butter(3, [0.2 15]/(facq/2), 'bandpass');
for electrodeIndex = 1:length(dataChannels)
    filteredData(electrodeIndex, :) = filtfilt(bDesign, aDesign, rawData(dataChannels(electrodeIndex), :));
end

%%
%Extract windows of all choices and non-choices

%the min index where a epoch can take 250ms before
minStartIndex = round(0.25*facq);
%the max index where a epoch can take 500ms after
maxEndIndex = length(rawData(channel, :)) - 0.5*facq;

%Extract windows containing 250ms before and 500ms after each choice
choiceWindows = zeros(length(dataChannels),length(choiceIndex),...
    round(0.75*facq));
for channel = 1:length(dataChannels)
    choiceWindow = 0;
    for i = choiceIndex
        %if a full window can be extracted
        if(i > minStartIndex && i < maxEndIndex)
            choiceWindow = choiceWindow + 1;
            choiceWindows(channel, choiceWindow, 1:round(0.75*facq)) = filteredData(...
                channel, round(choiceIndex(choiceWindow)-0.25*facq)...
                :choiceIndex(choiceWindow)+0.5*facq);
        else
            warning(strcat('Skipping flash because there is ',...
                'not a enough data ahead or behind the flash'));
        end
    end
end

%Extract windows containing 250ms before and 750ms after each non-choice
nChoiceWindows = zeros(length(dataChannels), length(nChoiceIndex),...
    round(0.75*facq));
for channel = 1:length(dataChannels)
    nChoiceWindow = 0;
    for i = nChoiceIndex
        if(i > minStartIndex && i < maxEndIndex)
            nChoiceWindow = nChoiceWindow+1;
            nChoiceWindows(channel, nChoiceWindow, 1:round(0.75*facq)) = ...
                filteredData(channel, round(nChoiceIndex(nChoiceWindow)...
                -0.25*facq):nChoiceIndex(nChoiceWindow)+0.5*facq);
        else
            warning(strcat('Skipping flash because there is ',...
                'not a enough data ahead or behind the flash'));
        end
    end
end

%%
%compute the average of the choice and non-choice windows
avgChoice = zeros(length(dataChannels),length(choiceWindows(1,1,:)));
avgNChoice = zeros(length(dataChannels),length(nChoiceWindows(1,1,:)));

%TODO: Make this compute the mean for each channel
for electrodeIndex = 1:length(choiceWindows(:,1,1))
    meanChoice = mean(choiceWindows(electrodeIndex,:,:));
    meanNChoice = mean(nChoiceWindows(electrodeIndex, :, :));
    
    avgChoice(electrodeIndex, :) = meanChoice(:);
    avgNChoice(electrodeIndex, :) = meanNChoice(:);
end
%%
%plot the avg choice vs the average not choice 

%figure containing the choice vs not choice plot
figure;
for electrodeIndex = 1:length(choiceWindows(:,1,1))
    subplot(round(length(choiceWindows(:,1,1))/2), 2, electrodeIndex);
    hold on;
    plot(-.25:dt:0.5, avgChoice(electrodeIndex,:));    
    plot(-.25:dt:0.5, avgNChoice(electrodeIndex,:));
    title([channels{electrodeIndex+1} ' choice vs not choice']);
    legend('Choice', 'Not Choice')
    hold off;
end

%%
%plots a normalized historgram of choice versus not choice

cHistogram = cell(length(dataChannels));
ncHistogram = cell(length(dataChannels));

figure;
for electrodeIndex = 1:length(choiceWindows(:, 1, 1))
    subplot(round(length(cHistogram(:,1,1))/2), 2, electrodeIndex);
    cHistogram{electrodeIndex} = histogram(avgChoice(electrodeIndex, :),...
        'NumBins', 25, 'Normalization', 'probability');
    hold on;
    ncHistogram{electrodeIndex} = histogram(avgNChoice(electrodeIndex, :),...
        'NumBins', 25, 'Normalization', 'probability');
    title([channels{electrodeIndex+1} ' choice vs not choice']);
    legend('Choice', 'Not Choice')
    hold off;
end

%%
%creates an average histogram of all epochs and channels for choice vs
%non-choice

%finds the mean of all 








