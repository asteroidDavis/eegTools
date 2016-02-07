function [ EOGdata ] = EogBandpass( Facq, Time, y)
%eogBandpass: Bandpass filter from 0.1-2Hz

    %sets up the filter
    [bLPEOG,aLPEOG] = butter(2,[.1 2]/(Facq/2),'bandpass');

    EOGdata = zeros(size(y,1), length(Time));
    for i = 1:8
        EOGdata(i, :) = filtfilt(bLPEOG, aLPEOG, y(i,:));
    end

end

