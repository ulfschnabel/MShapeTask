function ez_powerspec(y,Fs)
%ez power spectrum of vector y with sampling frequency Fs
%actually an amplitude spec at the moment

Nyq = Fs/2; %Nyquist limit is half the samplign frequency
%Sample time
Ts = 1/Fs;
%Length of time-series (in secs)
L = length(y)./Fs;
%Number of samples
N = length(y);

%Make samples and time-base
smps = 0:1:(N-1);
t = smps./Fs;

%FFT ANALYSIS%%%%%%%%%%%%%%%%%%
%First do fft, remember to scale by N.
Y = fft(y)/N;
%the resulting frequencies will be in cycles/timeseries
%starting with a frequency of 0 (DC) going upto frequencies that are equal to the length of the time-series-1.
%So the 2nd pos in the vector contains a frequency of 1 cycle/timeseries which has a
%frequency of 1/L;  This will continue upto Nyquist limit.
%So we can now make our frequency x-axis by diving the number of samples by the length of the time-series;
f = smps/L;
%Plot, use 2xamplitude as half of the amplitude will appear above Nyquist.
figure,plot(f,2.*abs(Y));
ylabel('Amplitude'),xlabel('Frequency (Hz)')
%Limit this at Nyquist
xlim([0 Nyq])
title('FFT of signal')

return