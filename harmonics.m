clear; clc; close all;

Fs = 1600;                   % Sampling freq (Hz)
Ts = 1/Fs;
T_end = 0.2;                 % Total time (s)
t = 0:Ts:T_end-Ts;           % Time vector
N_total = length(t);

f_true = 49.5*ones(size(t)); % Constant true frequency
omega_inst = 2*pi*cumsum(f_true)*Ts; % Instantaneous phase

% Generate signal with harmonics up to 13th
harmonics7  = [1,5,7];
harmonics13 = [1,5,7,11,13];
A = [230,15,10,6,4];
v = zeros(size(t));
for i = 1:length(harmonics13)
    v = v + A(i)*sin(harmonics13(i)*omega_inst);
end

% Sliding-window NLS estimator (10 ms window)
T_win    = 0.01;    
N_win    = round(T_win*Fs);
step     = 1;       
f_grid   = 48.5:0.1:51.5;

win7 = []; f7 = [];
win13 = []; f13 = [];
idx = 1;
while (idx + N_win - 1) <= N_total
    idx_win = idx:(idx + N_win - 1);
    t_win = (0:N_win-1)'*Ts;      % Local time axis
    v_win = v(idx_win);

    SSE7  = zeros(size(f_grid));
    SSE13 = zeros(size(f_grid));
    for j = 1:length(f_grid)
        f_test = f_grid(j);
        % build regressor for 7th-harmonic model
        M7 = [];
        for h = harmonics7
            M7 = [M7, sin(2*pi*f_test*h*t_win), cos(2*pi*f_test*h*t_win)];
        end
        a7 = (M7'*M7)\(M7'*v_win(:));
        SSE7(j) = sum((v_win(:) - M7*a7).^2);

        % build regressor for 13th-harmonic model
        M13 = [];
        for h = harmonics13
            M13 = [M13, sin(2*pi*f_test*h*t_win), cos(2*pi*f_test*h*t_win)];
        end
        a13 = (M13'*M13)\(M13'*v_win(:));
        SSE13(j) = sum((v_win(:) - M13*a13).^2);
    end

    % pick best freq and record center time
    [~, m7] = min(SSE7);
    [~, m13] = min(SSE13);
    f7(end+1)   = f_grid(m7);
    win7(end+1) = t(idx + N_win - 1) + Ts;
    f13(end+1)   = f_grid(m13);
    win13(end+1) = t(idx + N_win - 1) + Ts;

    idx = idx + step;  % slide window by one sample
end

% Plot input and estimates
figure('Position',[100 100 1000 800]);
subplot(3,1,1);
plot(t*1000, v, 'b-', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Voltage (V)');
title('Input Signal w/ Harmonics up to 13th');
grid on;

subplot(3,1,2);
plot(win7*1000, f7, 'r-', 'LineWidth',1.5); hold on;
plot(t*1000, f_true, 'k--', 'LineWidth',1);
legend('Est (up to 7th)','True','Location','best');
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
title('Sliding-Window Estimate (7th Harmonic)');
grid on;

subplot(3,1,3);
plot(win13*1000, f13, 'g-', 'LineWidth',1.5); hold on;
plot(t*1000, f_true, 'k--', 'LineWidth',1);
legend('Est (up to 13th)','True','Location','best');
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
title('Sliding-Window Estimate (13th Harmonic)');
grid on;
