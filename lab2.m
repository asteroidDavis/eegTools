%% analysis of the first EEG in BCI class
%
FileName = 'data\NateData_2016_1_28_14_57_14.mat';
load(FileName);
%%
yChanNames = {'Time','Counter','Status','Fz','Fp1','Fp2','Cz','C3','C4','O1','O2','InternalCount','TaskNo'};
taskNames = {'rest', 'clench teath', 'tense neck muscles', 'blink', 'roll eyes', 'electro-static', '60Hz'};

% extract the step numbers from the last channel
stepTimes = stepExtract(y(13, :));
Time = y(1,:);

% find the acquisition frequency
dt = mean(diff(y(1,:)));
Facq = 1/dt;

%creates a 4th order bandpass filter from 0.3Hz-35Hz
[b,a] = butter(4, [0.3 35]/(Facq/2), 'bandpass');
%creats a notch filter to reject common mode noise
[bNotch, aNotch] = butter(4, [58 62]/(Facq/2), 'stop');

taskNumber = 1;
%plots the channel vs time for each step in a new figure
for step = stepTimes
    %skips the first task because nothing was recorded yet
    if taskNumber == 1
       taskNumber = taskNumber + 1;
       continue;
    end
    figure;
    %adds titles to the figures and makes them large
    set(gcf, 'Position', [100, 100, 1049, 895], 'numbertitle', 'off',...
        'name', taskNames{taskNumber-1});
    %accesses every channel on the EEG
    for index = 4:11
        %filters the current data
        currentEEG = filtfilt(b, a, y(index, step{1}(1):step{1}(2)));
        currentEEGMinusCommon = filtfilt(bNotch, aNotch, currentEEG);
        
        %plots the filtered data
        subplot(4, 4, index-3);
        plot(Time(step{1}(1):step{1}(2)),currentEEG);
        xlabel('Time (s)');
        ylabel(yChanNames(index));
        
        %finds the number of points to use in the fourier transform
        NFFT = length(currentEEG);
        %performs a fourier transform of the EEG data
        fourierEEG = fft(currentEEG, NFFT);
        magnitudeEEG = abs(fourierEEG);
        F = ((0:1/NFFT:1-1/NFFT)*(1/dt));
        
        %plots the magnitude of each frequency
        subplot(4,4,(index-3)+8);
        plot(F, magnitudeEEG);
        xlabel('frequency (Hz)');
        ylabel(strcat('Magnitude of',yChanNames(index)));
        xlim([3 35]);
    end
    taskNumber = taskNumber + 1;
end




% %%
% figure;
% a(1) = subplot(2,1,1);
% plot(y(1,:),y(2,:));
% ylabel(yChanNames{2});
% a(2) = subplot(2,1,2);
% plot(y(1,5:end),diff(y(2,4:end)));
% ylabel(['diff(', yChanNames{2}, ')']);
% xlabel('Time (s)');
% linkaxes(a,'x');
% 
% %% 
% figure;
% plot(y(1,:),y(13,:));
% ylabel(yChanNames{13});
% xlabel('Time (s)');
% %% now extract the EEG data and apply a notch filter
% for ind = 4:11
%     y(ind,:) = y(ind,:)-y(ind,1);
% end
% EEGChans = [4:7,11];
% EOGChans = [8:9];
% [bLP,aLP] = butter(4,[1 35]/(Facq/2),'bandpass');
% [bLPEOG,aLPEOG] = butter(2,[.1 2]/(Facq/2),'bandpass');
% [bNotch,aNotch] = butter(4,[58 62]/(Facq/2),'stop');
% EEGdata = filtfilt(bLP,aLP,y(EEGChans,:)')';
% EOG_data = filtfilt(bLPEOG,aLPEOG,y(EOGChans,:)')';
% EOG_ReMix = [EOG_data(1,:)+EOG_data(2,:);EOG_data(2,:)-EOG_data(1,:)];
% Time = y(1,:);
% plot(Time,EEGdata(1,:));
% figure;
% plot(Time,EOG_ReMix);
% legend({'Eyes Up/Down','Eyes Right/Left'});
% %%
%     
%     
%     
