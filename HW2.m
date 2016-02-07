clc
clear all
close all

%chemical constants
kon = 0;
koff = 0;
Rtot = 1;

%time constants
minTime = 0;
maxTime = 0.01;
t = [0:10^-6:0.01];
dt = 10^-6;

%for 0 - 10ms
for time = t(1):dt:t(end)
    if time < 0.001 || time >= 0.02 
        L(time) = 0;
    elseif time >=0.01
        L(time) = 10e-6;
    end
end

for time = minTime:dt:maxTime
    LR(time+1) = LR(time) + (kon*L(time)*Rtot - (kon*L(time)+koff)*LR(time))*dt;
end 


%TODO: Initialize LR and L's size at the beginning