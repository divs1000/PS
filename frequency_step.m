clear; clc; close all;

%% 1. SIMULATION PARAMETERS
Fs = 1600;          % Sampling frequency (Hz)
Ts = 1/Fs;
T_end = 0.3;           % Total simulation time (s)
t = 0:Ts:T_end-Ts; % Time vector
N_total = length(t);

f_true = zeros(size(t));
step_time = 0.15;
for k = 1:N_total
    if t(k) < step_time
        f_true(k) = 49;
    else
        f_true(k) = 51;
    end
end

omega_inst = 2*pi*cumsum(f_true)*Ts;

%% 2. BUILD THE VOLTAGE SIGNAL v(t)
harmonics = [1, 5, 7, 11, 13];
A = [230, 15, 10, 6, 4];   % Example peak amplitudes

v = zeros(size(t));
for h_idx = 1:length(harmonics)
    h = harmonics(h_idx);
    v = v + A(h_idx)*sin(h*omega_inst);
end

%% 3. SLIDING-WINDOW FREQUENCY ESTIMATION (NLS)
T_window_20ms = 0.02;                % 20 ms window
T_window_10ms = 0.01;                % 10 ms window
N_window_20ms = round(T_window_20ms*Fs);
N_window_10ms = round(T_window_10ms*Fs);
step_size = 1;

f_candidates = 48.5:0.005:51.5;
allowed_harmonics = [1,5,7,11,13];

win_center_20ms = [];
f_estimated_20ms = [];

win_center_10ms = [];
f_estimated_10ms = [];

idx_start = 1;
while (idx_start + N_window_20ms - 1) <= N_total
    idx_win = idx_start:(idx_start + N_window_20ms - 1);
    t_win = (0 : N_window_20ms - 1)*1/Fs;
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
    
    win_center_20ms(end+1) = t(idx_start + N_window_20ms - 1) + 1/Fs;
    f_estimated_20ms(end+1) = best_freq;
    
    idx_start = idx_start + step_size;
end

idx_start = 1;
while (idx_start + N_window_10ms - 1) <= N_total
    idx_win = idx_start:(idx_start + N_window_10ms - 1);
    t_win = (0 : N_window_10ms - 1)*1/Fs;
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
    
    win_center_10ms(end+1) = t(idx_start + N_window_10ms - 1) + 1/Fs;
    f_estimated_10ms(end+1) = best_freq;
    
    idx_start = idx_start + step_size;
end

%% 4. PLOT RESULTS
figure('Name','Step Frequency Change with NLS Estimation','Position',[100 100 1000 800]);

subplot(3,1,1);
plot(t*1000, v, 'b-', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Voltage (V)');
title('Input Signal v(t) with a step change in Frequency');
grid on;

subplot(3,1,2);
plot(win_center_20ms*1000, f_estimated_20ms, 'r', 'LineWidth',1.5); hold on;
plot(t*1000, f_true, 'k--', 'LineWidth',1);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
legend('Estimated f (20ms)','True f','Location','best');
title('Time-Varying Frequency with T_{window} = 20ms');
grid on;

subplot(3,1,3);
plot(win_center_10ms*1000, f_estimated_10ms, 'g', 'LineWidth',1.5); hold on;
plot(t*1000, f_true, 'k--', 'LineWidth',1);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
legend('Estimated f (10ms)','True f','Location','best');
title('Time-Varying Frequency with T_{window} = 10ms');
grid on;
