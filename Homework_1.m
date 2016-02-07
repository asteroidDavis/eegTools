%%Homework_1  
% ESC 597B Spring 2016
%
% Getting Comfortable with Matlab
%
% NAME: Nathan Davis
% Date: 1/14/2016

clc, clear all, close all;
%% Create data
%  Create Four arrays of evenly spaced data (measurements in
%  time) - measured at 250 samples per second, 30 seconds of data
%  call them T, Y1, Y2, Trig 
%  where T is time 
T = 0:1/250:30;
%  Y1 = 3*sin(2*PI*5*T)   0<t<10 s
%  Y1 = 5*sin(2*PI*2*T)  10<t<20 s
%  Y1 = 1+3*sin(2*PI*8*T)  20<t<30 s
y1Generator = @(t)((3*sin(2*pi*5*t)).*(0<t & t<=10)...
    + (5*sin(2*pi*2*t)).*(10<t & t<=20) ...
    + (1+3*sin(2*pi*8*t)).*(20<t & t<=30));
Y1 = y1Generator(T);
%
%  Y2 is the square (on a point by point basis) of Y1
Y2 = Y1.^2;

%  Trig = 1   0<t<10 s
%  Trig = 2  10<t<20 s
%  Trig = 3   20<t<30 s
trigGenerator = @(t)(1.*(0<t & t<=10) ...
    + 2.*(10<t & t <=20) ...
    + 3.*(20<t & t <=30));
Trig = trigGenerator(T);
%
%  Now Plot the data full time series.  Put Y1 and Y2 in separate panels,
%  with Y2 below Y1 on the same figure page
%  (hint - use subplot, ylabel, title)
figure
subplot(2, 1,1);
plot(T, Y1);
ylabel('Y1');
xlabel('time (s)');
title('Non-continuous sin wave');

subplot(2,1,2);
plot(T, Y2);
ylabel('Y2');
xlabel('time (s)');
title('Squared non-continuous sin wave');
%% Now make expanded views of the data in time

%plots continuous views of Y1 at the top of the figure
FigHandle = figure;
set(FigHandle, 'Position', [100, 100, 1049, 895]);
subplot(6, 1, 1);
plot(T, Y1);
xlim([0 10]);
title('Y1 continuous views');

subplot(6, 1, 2);
plot(T, Y1);
xlim([10 20]);

subplot(6, 1, 3);
plot(T, Y1);
xlim([20 30]);
xlabel('time (s)');

%plots continuous views of Y2 at the bottom of the figure
subplot(6, 1, 4);
plot(T, Y2);
xlim([0 10]);
title('Y2 continuous views');

subplot(6, 1, 5);
plot(T, Y2);
xlim([10 20]);

subplot(6, 1, 6);
plot(T, Y2);
xlim([20 30]);
xlabel('time (s)');


%%  Now plot the Y2 vs Y1 for all time on the same graph, but make each time
%   period a different color line.  Make sure to include a legend.
figure
plot(T, Y1, 'r', T, Y2, 'b');
legend('Y1', 'Y2');
title('Y1 and Y2 vs time');
xlabel('time (s)');
%% Now compute statistics
%  calculate the cumulative probability distribution (cdf) of Y1 and Y2 
%  for cases where Trig = 1; Trig = 2; Trig = 3
%  Hint: you could use a command such as find(Trig==1)

%finds the domains for computing the cdf
firstContinuityIndex = find(Trig == 1);
secondContinuityIndex = find(Trig == 2);
thirdContinuityIndex = find(Trig == 3);

%calculates the cdf of each continuity for Y1
[firstY1Cdf, firstY1CdfStats] = ecdf(Y1(firstContinuityIndex));
[secondY1Cdf, secondY1CdfStats] = ecdf(Y1(secondContinuityIndex));
[thirdY1Cdf, thirdY1CdfStats] = ecdf(Y1(thirdContinuityIndex));
%calculates the cdf of each continuity for Y2
[firstY2Cdf, firstY2CdfStats] = ecdf(Y2(firstContinuityIndex));
[secondY2Cdf, secondY2CdfStats] = ecdf(Y2(secondContinuityIndex));
[thirdY2Cdf, thirdY2CdfStats] = ecdf(Y2(thirdContinuityIndex));

%plots the results of the Y1 cdf
figure
subplot(3, 2, 1);
plot(firstY1Cdf);
title('Cumulative Distributions of Y1');

subplot(3, 2, 3);
plot(secondY1Cdf);
ylabel('probability')

subplot(3, 2, 5);
plot(thirdY1Cdf);
xlabel('time (1/250s)')

%plots the Y2 cdf
subplot(3, 2, 2);
plot(firstY2Cdf);
title('Cumulative Distributions of Y2');

subplot(3, 2, 4);
plot(secondY2Cdf);
ylabel('probability')

subplot(3, 2, 6);
plot(secondY2Cdf);
xlabel('time (1/250s)')


