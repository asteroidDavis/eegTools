%% Spectral Estimation Tutorial
%  Bruce J. Gluckman
%  revised 2/2016 (original 1/26/09)
%
%  It is also helpful to read the Matlab help files for:
%     fft
%
%% make some raw data
%
SPS = 256;      %data rate, samples-per-second
%
Tmax = 1;  % chose as 2^m
Time = 1/SPS:1/SPS:Tmax;
NPTS = length(Time);
F1 = 12;
F2 = 33;
twopi=2*pi;
Y1 = sin(twopi*F1*Time);
Y2 = 3 * sin(twopi*F2*Time);
Y3 = 4 * randn(size(Time));
Y4 = Y1 + Y2 + Y3 ;
figure;
fig1.a(1) = subplot(4,1,1);
plot(Time,Y1);
ylabel('Y1');
%
title('Generate Raw Data');
%
fig1.a(2) = subplot(4,1,2);
plot(Time,Y2);
ylabel('Y2');
fig1.a(3) = subplot(4,1,3);
plot(Time,Y3);
ylabel('Y3');
fig1.a(4) = subplot(4,1,4);
plot(Time,Y4);
ylabel('Y4');
%
xlabel('Time (s)');
linkaxes(fig1.a,'x');
%
%% Now compute the FFT
%
% note that NPTS = 2^n by construction, as long as we chose 
fY1 = fft(Y1,NPTS);
fY2 = fft(Y2,NPTS);
fY3 = fft(Y3,NPTS);
fY4 = fft(Y4,NPTS);
%
% now these fourier transforms are complex values, and scrambled in a way
% peculariar to the fft - specifically, the fft is done on blocks NPTS=2^n long
% with total window length TWindow = NPTS*dt = NPTS/SPS
% so the output has resolution deltaF=1/TWindow
% and max or minimal frequency at the Nyquist frequency Fn=SPS/2
% so the full range of values goes from -Fn<=F<=Fn
% Counting zero, this should lead to NPTS+1 values, but we only get out
% NPTS values, and in what order?
% It should be realized that the result for -Fn must equal that for Fn
% It is still scrambled:
% The first value is at the F=0, it progresses through Fn, then switches to
% -Fn/2+deltaF and goes up to -deltaF
%
deltaF = 1/Tmax;
Fn = SPS/2;
F = [0:deltaF:Fn , -Fn+deltaF:deltaF:-deltaF];
% Now plot the magnitude of these spectra (recall they are complex
%
norm = SPS/2;
figure;
fig2.a(1) = subplot(4,1,1);
plot(F,abs(fY1)/norm);
ylabel('abs(fY1)/f_N');
grid on;
%
title('Fourier Analysis');
%
fig2.a(2) = subplot(4,1,2);
plot(F,abs(fY2)/norm);
ylabel('abs(fY2)/f_N');
grid on;
fig2.a(3) = subplot(4,1,3);
plot(F,abs(fY3)/norm);
ylabel('abs(fY3)/f_N');
grid on;
fig2.a(4) = subplot(4,1,4);
plot(F,abs(fY4)/norm);
ylabel('abs(Y4)/f_N');
grid on;
%
xlabel('Frequency (Hz)');
linkaxes(fig2.a,'xy');
xlim([-128 128]);
ylim([0 5]);
%
%% Better plotting - plot positive frequencies
%  notice that the negative amplitude is the same as the positive
%  amplitudes this follows from the data being REAL
%
%  plot positive frequencies
%
%  it is also better to plot the POWER, defined by the 
%  magnitude squared (actually gotten from multiplying by the complex
%  congugate
%
range = 1:length(F)/2+1;
pfY1 = fY1.*conj(fY1)/(norm*norm);
pfY2 = fY2.*conj(fY2)/(norm*norm);
pfY3 = fY3.*conj(fY3)/(norm*norm);
pfY4 = fY4.*conj(fY4)/(norm*norm);
figure;
fig3.a(1) = subplot(4,1,1);
plot(F(range),log10(pfY1(range)));
ylabel('logpower(fY1)/{f_N}^2');
%
title('Fourier Analysis - semilog');
%
fig3.a(2) = subplot(4,1,2);
plot(F(range),log10(pfY2(range)));
ylabel('logpower(fY2)/{f_N}^2');
fig3.a(3) = subplot(4,1,3);
plot(F(range),log10(pfY3(range)));
ylabel('logpower(fY3)/{f_N}^2');
fig3.a(4) = subplot(4,1,4);
plot(F(range),log10(pfY4(range)));
ylabel('logpower(fY4)/{f_N}^2');
%
xlabel('Frequency (Hz)');
linkaxes(fig3.a,'xy');
ylim([-35 3]);
xlim([0 128]);
%% Now vectorize to make much easier
%
Y = [Y1-mean(Y1); Y2-mean(Y2); Y3-mean(Y3); Y4-mean(Y4)];
%  Note that I've demeaned the signals!
%  ALSO NOTE - for a matrix, define which dimension you mean to transform
fY = fft(Y,NPTS,2);
pfY = fY.*conj(fY);
figure;
yLabels = {'logpower(fy1)','logpower(fy2)','logpower(fy3)','logpower(fy4)'};
% need to pick the minimum and maximum - excluding zero
pmin=min(min(pfY(:,2:NPTS)))/10;
pmax=100*max(max(pfY(:,2:NPTS)));
for i=1:4
    fig4.a(i) = subplot(4,1,i);
    if (i == 1)
        title('Fourier Analysis - vectorized');
    end
    semilogy(F(range),pfY(i,range));
    ylim([pmin pmax]);
    ylabel(yLabels(i));
end
xlabel('Frequency (Hz)');
linkaxes(fig4.a,'x');


%% Relation between signal variance and Fourier Power? 
var_Y = var(Y');
sum_pfY = sum(pfY');
figure; 
plot(var_Y,sum_pfY,'ro');
xlabel('variance(Y)');
ylabel('sum power');
title('variance and Fourier Power');
%% Total Variance = Total Power (with normalization)
%
% Find normalization
% use A/B finds least squares fit between them
%
slope = mean(sum_pfY/var_Y)
% what is this value?  square of NPTS!
plot(var_Y, var_Y, 'g--',...
    var_Y,sum_pfY/(NPTS*NPTS),'ro',...
    'MarkerSize',10);
xlabel('variance(Y)');
ylabel('sum power/(npts^2)');
title('variance and Fourier Power');

