%%
%Loads the data
clc, clear all, close all

FileName = 'JustAcquire\NateData_2016_1_28_14_57_14.mat';
load(FileName);

%%
%Extracts timeing info and sets up channel names
yChanNames = {'Time','Counter','Status','Fz','Fp1','Fp2','Cz','C3','C4','O1','O2','InternalCount','TaskNo'};
taskNames = {'rest', 'clench teath', 'tense neck muscles', 'blink', 'roll eyes', 'electro-static', '60Hz'};

% extract the step numbers from the last channel
stepTimes = stepExtract(y(13, :));
Time = y(1,:);

% find the acquisition frequency
dt = mean(diff(y(1,:)));
Facq = 1/dt;

%Find the frequency for the nyquist filter
Fn = Facq/2;

%%
%bandpass filters the EEG data between minF and maxF
minF = 0.3;
maxF = 35;

FnEeg = Bandpass4(Facq, Time, minF, maxF, y(4:11, :));

%%
%filters out 60 Hz common noise

cleanEEG = filterOutCommon(Facq, Time, y(4:11, :));

%%
%bandpass filters EOGs which should be <1Hz
EOGdata = EogBandpass(Facq, Time, cleanEEG);

%%
%Fourier transforms each channel
Feeg = zeros(8, length(Time));
for i = 4:11
    %The fourier transform of the eeg
    Feeg(i-3,:) = fft(FnEeg(i-3, :), length(Time));
end

%%
%Testing out plotting

plotTasksInChannels(Feeg, stepTimes, Facq, yChanNames(4:11), taskNames,...
    'Frequenzy (Hz)', 'Bandpass filtered frequency Domain'); 

%%
%plots the magnitude of the frequency domain for each step and channel
%steps are different colors. 
%Channels are different plots

figure;
set(gcf, 'Position', [100, 100, 1049, 895], 'numbertitle', 'off',...
        'name', 'Bandpass filtered frequency Domain');

colors = 'ymcrgbky';
%for each electrode
for i = 4:11
    %plots for frequency data
    subplot(4, 2, i-3);
    colorIndex = 1;
    %for each task
    for step = stepTimes
        %determines the frequency domain of each step
        deltaF = length(step{1}(1):step{1}(2));
        F = -Fn+Facq/deltaF:Facq/deltaF:Fn;
        %plots for frequency data
        plot(F, abs(Feeg(i-3,step{1}(1):step{1}(2)))/Fn, colors(colorIndex));
        hold on;
        colorIndex = colorIndex + 1;
    end
    xlim([0 Fn]);
    xlabel('Frequenzy (Hz)');
    ylabel(strcat('|',yChanNames(i),'| (mV)'));
end

legend(taskNames, 'Location', 'bestoutside');
%%
%plots the time series of EEG measurements for each task

figure;
set(gcf, 'Position', [100, 100, 1049, 895], 'numbertitle', 'off',...
        'name', 'Raw Data');
%foreach electrode
for i = 4:11
    %plot for raw data
    subplot(4, 2, i-3);
    %for each measurement
    for step = stepTimes
        %plots the raw data
        plot(Time(step{1}(1):step{1}(2)), y(i, step{1}(1):step{1}(2)));
        hold on;
    end
end

%%
%calculates the power of each signal
Peeg = zeros(8, length(Time));
for i = 1:8
    %The fourier transform of the eeg
    Peeg(i,:) = Feeg(i, :).*conj(Feeg(i, :))/Fn^2;
end 

%%
%plots the power density of each channel and task
figure;
set(gcf, 'Position', [100, 100, 1049, 895], 'numbertitle', 'off',...
        'name', 'Power Density');

%for each channel
for i=1:8
    subplot(4, 2, i);
    %for each task
    for step = stepTimes
        %determines the frequency domain of each step
        deltaF = length(step{1}(1):step{1}(2));
        F = -Fn+Facq/deltaF:Facq/deltaF:Fn;
        %plots the power desity of the current channel and task
        plot(F, log10(Peeg(i, step{1}(1):step{1}(2))));
        hold on;
    end
    xlim([0 Fn]);
    xlabel('Frequenzy (Hz)');
    ylabel(strcat('logpower(',yChanNames(i),'/Fn^2'));
end    
legend(taskNames, 'Location', 'bestoutside');










