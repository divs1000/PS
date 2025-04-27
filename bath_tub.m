%% BATH-TUB FREQUENCY SIMULATION WITH NLS ESTIMATION
clear; clc; close all;

Fs = 1600;
Ts = 1/Fs;
T_end = 0.3;
t = 0:Ts:T_end-Ts;
N_total = length(t);

f_true = zeros(size(t));
for k = 1:N_total
    tk = t(k);
    if tk < 0.05
        f_true(k) = 50;
    elseif tk < 0.10
        alpha = (tk - 0.05)/(0.10 - 0.05);
        f_true(k) = 50 + alpha*(49.8 - 50);
    elseif tk < 0.15
        f_true(k) = 49.8;
    elseif tk < 0.20
        alpha = (tk - 0.15)/(0.20 - 0.15);
        f_true(k) = 49.8 + alpha*(50 - 49.8);
    else
        f_true(k) = 50;
    end
end

omega_inst = 2*pi*cumsum(f_true)*Ts;

harmonics = [1, 5, 7, 11, 13];
A = [230,  15, 10, 6, 4];

v = zeros(size(t));
for h_idx = 1:length(harmonics)
    h = harmonics(h_idx);
    v = v + A(h_idx)*sin(h*omega_inst);
end

T_window = 0.02;
N_window = round(T_window*Fs);
step_size = 1;

f_candidates = 48.5:0.005:51.5;
allowed_harmonics = [1,5,7,11,13];

win_center = [];
f_estimated = [];

idx_start = 1;
while (idx_start + N_window - 1) <= N_total
    idx_win = idx_start:(idx_start + N_window - 1);
    t_win = (0 : N_window - 1)*1/Fs;
    v_win = v(idx_win);
    
    SSE = zeros(size(f_candidates));
    
    for iF = 1:length(f_candidates)
        f_test = f_candidates(iF);
        
        M = [];
        for hh = allowed_harmonics
            M = [M, sin(2*pi*f_test*hh*t_win(:)), cos(2*pi*f_test*hh*t_win(:))];
        end
        
        a_hat = (M'*M) \ (M'*v_win(:));
        
        v_fit = M*a_hat;
        err = v_win(:) - v_fit;
        SSE(iF) = sum(err.^2);
    end
    
    [~, idx_min] = min(SSE);
    best_freq = f_candidates(idx_min);
    
    win_center(end+1) = t(idx_start + N_window/2);
    f_estimated(end+1) = best_freq;
    
    idx_start = idx_start + step_size;
end

f_true_win = interp1(t, f_true, win_center, 'linear', 'extrap');
f_error = f_estimated - f_true_win;

figure('Name','Bath-Tub Frequency NLS','Position',[100 100 1000 800]);

subplot(3,1,1);
plot(t*1000, v, 'b-', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Voltage (V)');
grid on;

subplot(3,1,2);
plot(win_center*1000, f_estimated, 'r', 'LineWidth',1.5); hold on;
plot(t*1000, f_true, 'k--', 'LineWidth',1);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
grid on;

subplot(3,1,3);
plot(win_center*1000, f_error, 'm.-', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Frequency Error (Hz)');
grid on;