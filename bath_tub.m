%% BATH-TUB FREQUENCY SIMULATION WITH NLS ESTIMATION
clear; clc; close all;

Fs = 1600;                     % Sampling freq (Hz)
Ts = 1/Fs;
T_end = 0.3;                   % Total time (s)
t = 0:Ts:T_end-Ts;             % Time vector
N_total = length(t);

% Construct “bath-tub” frequency profile
f_true = zeros(size(t));
for k = 1:N_total
    tk = t(k);
    if tk < 0.05
        f_true(k) = 50;
    elseif tk < 0.10
        alpha = (tk - 0.05)/0.05;
        f_true(k) = 50 + alpha*(49.8 - 50);
    elseif tk < 0.15
        f_true(k) = 49.8;
    elseif tk < 0.20
        alpha = (tk - 0.15)/0.05;
        f_true(k) = 49.8 + alpha*(50 - 49.8);
    else
        f_true(k) = 50;
    end
end

omega_inst = 2*pi*cumsum(f_true)*Ts;  % Instantaneous phase

% Build multi-harmonic signal
harmonics = [1, 5, 7, 11, 13];
A = [230, 15, 10, 6, 4];
v = zeros(size(t));
for i = 1:length(harmonics)
    v = v + A(i)*sin(harmonics(i)*omega_inst);
end

% Sliding-window NLS estimator
T_window = 0.02;                        % Window length (s)
N_window = round(T_window*Fs);          % Samples per window
step_size = 1;                          % Slide by one sample
f_candidates = 48.5:0.005:51.5;         % Search grid
allowed_harmonics = harmonics;

win_center = [];
f_estimated = [];

idx = 1;
while (idx + N_window - 1) <= N_total
    idx_win = idx:(idx + N_window - 1);
    v_win = v(idx_win);
    t_win = (0:N_window-1)'*Ts;         % Local time axis
    
    SSE = zeros(size(f_candidates));
    for j = 1:length(f_candidates)
        f_test = f_candidates(j);
        M = [];
        for hh = allowed_harmonics
            M = [M, sin(2*pi*f_test*hh*t_win), cos(2*pi*f_test*hh*t_win)];
        end
        a_hat = (M'*M)\(M'*v_win(:));    % LS fit
        err = v_win(:) - M*a_hat;
        SSE(j) = sum(err.^2);
    end
    
    [~, jmin] = min(SSE);
    f_estimated(end+1) = f_candidates(jmin);
    win_center(end+1)   = t(idx + floor(N_window/2));  % Center time
    
    idx = idx + step_size;  % Slide window
end

% True freq at window centers and error
f_true_win = interp1(t, f_true, win_center, 'linear', 'extrap');
f_error     = f_estimated - f_true_win;

% Plot results
figure('Name','Bath-Tub Frequency NLS','Position',[100 100 1000 800]);

subplot(3,1,1);
plot(t*1000, v, 'b-', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Voltage (V)');
title('Input Signal with Bath-Tub Frequency + Harmonics');
grid on;

subplot(3,1,2);
plot(win_center*1000, f_estimated, 'r-', 'LineWidth',1.5); hold on;
plot(t*1000, f_true, 'k--','LineWidth',1);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
legend('Estimated f','True f','Location','best');
title('Bath-Tub Frequency Tracking (02 s Window)');
grid on;

subplot(3,1,3);
plot(win_center*1000, f_error, 'm.-', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Error (Hz)');
title('Estimation Error \Delta f');
grid on;

