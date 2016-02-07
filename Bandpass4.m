function [ fData ] = Bandpass4( Facq, Time, minF, maxF, y)
%Bandpass4: 4th order bandpass filters between minF and maxF
    %sets up the filter
    [b,a] = butter(4, [minF maxF]/(Facq/2), 'bandpass');

    fData = zeros(size(y,1), length(Time));
    for i = 1:8
        fData(i,:) = filtfilt(b, a, y(i,:));
    end
end

