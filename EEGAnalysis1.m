%% analysis of the first EEG in BCI class
%
FileName = 'NateData_2016_1_28_15_5_32.mat';
load(FileName);
%%
yChanNames = {'Time','Counter','Status','Cz','Pz','C3','C4','EOGl','EOGr','Broken','CP3','InternalCount','TaskNo'};
%%
figure;
a(1) = subplot(2,1,1);
plot(y(1,:),y(2,:));
ylabel(yChanNames{2});
a(2) = subplot(2,1,2);
plot(y(1,5:end),diff(y(2,4:end)));
ylabel(['diff(', yChanNames{2}, ')']);
xlabel('Time (s)');
linkaxes(a,'x');
%% find the acquisition frequency
dt = mean(diff(y(1,:)));
Facq = 1/dt;
%% 
figure;
plot(y(1,:),y(13,:));
ylabel(yChanNames{13});
xlabel('Time (s)');
%% now extract the EEG data and apply a notch filter
for ind = 4:11
    y(ind,:) = y(ind,:)-y(ind,1);
end
EEGChans = [4:7,11];
EOGChans = [8:9];
[bLP,aLP] = butter(4,[1 35]/(Facq/2),'bandpass');
[bLPEOG,aLPEOG] = butter(2,[.1 2]/(Facq/2),'bandpass');
[bNotch,aNotch] = butter(4,[58 62]/(Facq/2),'stop');
EEGdata = filtfilt(bLP,aLP,y(EEGChans,:)')';
EOG_data = filtfilt(bLPEOG,aLPEOG,y(EOGChans,:)')';
EOG_ReMix = [EOG_data(1,:)+EOG_data(2,:);EOG_data(2,:)-EOG_data(1,:)];
Time = y(1,:);
plot(Time,EEGdata(1,:));
figure;
plot(Time,EOG_ReMix);
legend({'Eyes Up/Down','Eyes Right/Left'});
%% extract the step numbers from the last channel
stepTimes = stepExtract(y(13, :));
    
    
    
