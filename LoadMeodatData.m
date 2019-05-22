close all;
clear all;


%% Programm initialization
Fs = 4.5e9;         % sampling frequency
c = 3e8;
dt = 1/Fs;          % sampling interval

% calculate PRF
AveRate = 8;
PRI = 511*512*256*AveRate/Fs;
PRF = 1/PRI;



% read dataset 
file='Fast2.0000000000';

[Ch1,Ch2] = ReadMeodat(file);

[NSampleCount,NAscanCount] = size(Ch1);
SlowTime = 0:PRI:(NAscanCount-1)*PRI;
FastTime = 0:dt:(NSampleCount-1)*dt;

range = c./(2) .* (0:dt:(NSampleCount-1)*dt);


figure(1);

imagesc(SlowTime,FastTime/1e-9,Ch1);colormap(bone);title('B-scan of Ch1');xlabel('Slow time[s]');ylabel('Fast time[ns]');colorbar;
caxis([0 0.011]);

figure(7);
plot(FastTime*10^9, Ch1(:, 1), 'LineWidth', 2);

xlabel('time(nS)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Signal(mV)', 'FontSize', 12, 'FontWeight', 'bold');
title(['Signal Received'], 'FontSize', 12, 'FontWeight', 'bold');
grid on;

%legend({'k_{\rho g}(f_i)(TE)', 'k_{\rho g}(f_i)(TM)'}, 'Location', 'north', 'FontSize', 12, 'FontWeight', 'bold');

% 
%figure;imagesc(SlowTime,FastTime/1e-9,Ch2);colormap(bone);title('B-scan of Ch2');xlabel('Slow time[s]');ylabel('Fast time[ns]');colorbar;

%% Background elimination 


% plot(FastTime, Ch1(:, 1), 'LineWidth', 2);
% hold on;
% plot(FastTime, Ch1(:, 2), 'LineWidth', 2);

%Ch1_mean = mean(Ch1, 2);
Ch1_mean = mean(Ch1, 2);
Ch1_new = Ch1 - Ch1_mean;

figure(8);

plot(FastTime*10^9, Ch1_new(:, 1), 'LineWidth', 2);

xlabel('time(nS)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Signal(mV)', 'FontSize', 12, 'FontWeight', 'bold');
title(['Signal Received after background subtraction'], 'FontSize', 12, 'FontWeight', 'bold');

grid on;

[v, Ind] = max(Ch1_new(:, 1));

%Ch1_new_freq = fft(Ch1_win, [], 2);

%Ch1_new_freq = fftshift(fft2(Ch1_win), 2);

%Ch1_new_1 = cat(2, Ch1_new, zeros(2000-size(Ch1_new, 2), size(Ch1_new, 2)));
To_cat = zeros(size(Ch1_new, 1), 4000);
Ch1_new_1 = horzcat(Ch1_new, To_cat);

Ch1_new_freq = fftshift(fft(Ch1_new_1, [], 2));

freq_count = linspace(-NAscanCount/2, NAscanCount/2 - 1, size(Ch1_new_1, 2));
frequencies = PRF .* freq_count./NAscanCount;
%frequencies = PRF .* (0:NAscanCount/2)./NAscanCount;%



figure(2);

imagesc(SlowTime,FastTime/1e-9,Ch1_new);colormap(bone);title('B-scan of Ch1\_new');xlabel('Slow time[s]');ylabel('Fast time[ns]');colorbar;
caxis([0 0.001]);

%figure;imagesc(SlowTime,FastTime/1e-9,Ch1_win);colormap(bone);title('B-scan of Ch1 win');xlabel('Slow time[s]');ylabel('Fast time[ns]');colorbar;


figure(3);
plot(FastTime, Ch1_new(:, 1), 'LineWidth', 2);
grid on;

figure(4);

plot(SlowTime, Ch1_new(Ind, :), 'LineWidth', 2);

xlabel('time(nS)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Breathing signal peak oveer slow time(mVolt)', 'FontSize', 12, 'FontWeight', 'bold');
title(['Breathing signal in time domain'], 'FontSize', 12, 'FontWeight', 'bold');

grid on;



figure(5);

surf(frequencies, range, abs(Ch1_new_freq)); view(2); shading flat;
xlim([-2 2]);
ylim([12 16]);
caxis([0 0.02]);
colormap(jet);

xlabel('Frequency of breathing (Hz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Range [meters]', 'FontSize', 12, 'FontWeight', 'bold');
title(['Range-Doppler plot in the case of fast breathing'], 'FontSize', 12, 'FontWeight', 'bold');
colorbar;
print('RD_fast', '-depsc');


frequencies_1 = PRF .* (0: NAscanCount/2)./NAscanCount;
Ch1_new_freq_1 = fft(Ch1_new, [], 2);



figure(6);

plot(frequencies_1, abs(Ch1_new_freq_1(Ind, 1:NAscanCount/2+1)).^2/NAscanCount, 'LineWidth', 2);

xlabel('Frequency(Hz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('P_{yy} (Linear Scale)', 'FontSize', 12, 'FontWeight', 'bold');
title(['Spectrum of breathing signal received'], 'FontSize', 12, 'FontWeight', 'bold');

grid on;

%print('Fast_spectrum', '-depsc');

% figure(10);
% 
% plot(frequencies_1, 0.5 .* db(abs(Ch1_new_freq_1(Ind, 1:NAscanCount/2+1))).^2/NAscanCount, 'LineWidth', 2);
% 
% xlabel('Frequency(Hz)', 'FontSize', 12, 'FontWeight', 'bold');
% ylabel('P_{yy} (dB Scale)', 'FontSize', 12, 'FontWeight', 'bold');
% title(['Spectrum of breathing signal received'], 'FontSize', 12, 'FontWeight', 'bold');
% 
% grid on;
% 
% print('Slow_spectrum_dB', '-depsc');

%% Ambiguity function:

% Fs = 1./(dt);
% 
% [afmag, delay, doppler] = ambgfun(Ch1_new(Ind, :), Fs, PRF);
% 
% figure;
% contour(delay, doppler, afmag)


