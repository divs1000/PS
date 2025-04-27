clear; clc; close all;

Fs = 1600;
Ts = 1/Fs;
T_end = 0.2;
t = 0:Ts:T_end-Ts;
N_total = length(t);

f_true = 49.5 * ones(size(t));

omega_inst = 2*pi*cumsum(f_true)*Ts;

harmonics_7 = [1, 5, 7];
harmonics_13 = [1, 5, 7, 11, 13];
A = [230, 15, 10, 6, 4];

v = zeros(size(t));
for h_idx = 1:length(harmonics_13)
    h = harmonics_13(h_idx);
    v = v + A(h_idx)*sin(h*omega_inst);
end

T_window_10ms = 0.01;
N_window_10ms = round(T_window_10ms*Fs);
step_size = 1;

f_candidates = 48.5:0.1:51.5;

win_center_7 = [];
f_estimated_7 = [];

win_center_13 = [];
f_estimated_13 = [];

idx_start = 1;
while (idx_start + N_window_10ms - 1) <= N_total
    idx_win = idx_start:(idx_start + N_window_10ms - 1);
    t_win = (0 : N_window_10ms - 1)*1/Fs;
    v_win = v(idx_win);
    
    SSE_7 = zeros(size(f_candidates));
    SSE_13 = zeros(size(f_candidates));
    
    for iF = 1:length(f_candidates)
        f_test = f_candidates(iF);
        
        M_7 = [];
        for hh = harmonics_7
            M_7 = [M_7, sin(2*pi*f_test*hh*t_win(:)), cos(2*pi*f_test*hh*t_win(:))];
        end
        
        a_hat_7 = (M_7'*M_7) \ (M_7'*v_win(:));
        v_fit_7 = M_7*a_hat_7;
        err_7 = v_win(:) - v_fit_7;
        SSE_7(iF) = sum(err_7.^2);
    end
    
    for iF = 1:length(f_candidates)
        f_test = f_candidates(iF);
        
        M_13 = [];
        for hh = harmonics_13
            M_13 = [M_13, sin(2*pi*f_test*hh*t_win(:)), cos(2*pi*f_test*hh*t_win(:))];
        end
        
        a_hat_13 = (M_13'*M_13) \ (M_13'*v_win(:));
        v_fit_13 = M_13*a_hat_13;
        err_13 = v_win(:) - v_fit_13;
        SSE_13(iF) = sum(err_13.^2);
    end
    
    [~, idx_min_7] = min(SSE_7);
    best_freq_7 = f_candidates(idx_min_7);
    
    [~, idx_min_13] = min(SSE_13);
    best_freq_13 = f_candidates(idx_min_13);
    
    win_center_7(end+1) = t(idx_start + N_window_10ms - 1) + 1/Fs;
    f_estimated_7(end+1) = best_freq_7;
    
    win_center_13(end+1) = t(idx_start + N_window_10ms - 1) + 1/Fs;
    f_estimated_13(end+1) = best_freq_13;
    
    idx_start = idx_start + step_size;
end

figure('Name','Step Frequency Change with NLS Estimation','Position',[100 100 1000 800]);

subplot(3,1,1);
plot(t*1000, v, 'b-', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Voltage (V)');
title('Input Signal v(t) with Harmonics up to 13');
grid on;

subplot(3,1,2);
plot(win_center_7*1000, f_estimated_7, 'r', 'LineWidth',1.5); hold on;
plot(t*1000, f_true, 'k--', 'LineWidth',1);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
legend('Estimated f (Up to 7th Harmonic)','True f','Location','best');
title('Time-Varying Frequency with Harmonics up to 7');
grid on;

subplot(3,1,3);
plot(win_center_13*1000, f_estimated_13, 'g', 'LineWidth',1.5); hold on;
plot(t*1000, f_true, 'k--', 'LineWidth',1);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
legend('Estimated f (Up to 13th Harmonic)','True f','Location','best');
title('Time-Varying Frequency with Harmonics up to 13');
grid on;