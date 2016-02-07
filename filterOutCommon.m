function [ cleanEEG ] = filterOutCommon( Facq, Time, y)
%filterOutCommon Notch filter between 58 and 62 Hz
    
    %sets up the filter
    [bNotch, aNotch] = butter(4, [58 62]/(Facq/2), 'stop');

    cleanEEG = zeros(size(y,1), length(Time));
    for i = 1:8
        cleanEEG(i, :) = filtfilt(bNotch, aNotch, y(i, :));
    end

end

