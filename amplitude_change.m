clear; clc; close all;

Fs      = 1600;               
Ts      = 1/Fs;
T_end   = 0.3;                
t       = 0:Ts:T_end-Ts;      
N_total = length(t);

f0      = 50;                 
A1 = 230;                     
step_time = 0.15;             
A2 = A1 * 1.15;               

A = A1 * ones(size(t));
A(t >= step_time) = A2;

h3_fraction = 0.10;   
h5_fraction = 0.05;
phase3 = pi/6;     
phase5 = -pi/8;    

v = A .* sin(2*pi*f0*t) ...
    + (h3_fraction * A) .* sin(2*pi*5*f0*t + phase3) ...
    + (h5_fraction * A) .* sin(2*pi*7*f0*t + phase5);

window_sizes = [0.01, 0.02];   
f_candidates = 48.5:0.01:51.5;  

allowed_harmonics = [1, 5, 7, 11, 13];

step_size = 1;

results = struct();

for ws = 1:length(window_sizes)
    T_window = window_sizes(ws);
    N_window = round(T_window * Fs);   
    num_estimates = N_total - N_window + 1;
    
    f_est = zeros(num_estimates,1);      
    win_center = zeros(num_estimates,1);   
    
    idx = 1;
    while (idx + N_window - 1) <= N_total
        idx_win = idx:(idx + N_window - 1);
        t_win = t(idx_win);
        v_win = v(idx_win);
        
        SSE = zeros(size(f_candidates));
        for iF = 1:length(f_candidates)
            f_test = f_candidates(iF);
            M = [];
            for hh = allowed_harmonics
                M = [M, sin(2*pi*f_test*hh*t_win(:)), cos(2*pi*f_test*hh*t_win(:))];
            end
            
            a_hat = (M'*M) \ (M'*v_win(:));
            v_fit = M * a_hat;
            err   = v_win(:) - v_fit;
            SSE(iF) = sum(err.^2);
        end
        
        [~, idx_min] = min(SSE);
        best_freq = f_candidates(idx_min);
        
        win_center(idx) = t_win(end) + 1/Fs;
        f_est(idx) = best_freq;
        
        idx = idx + step_size;
    end
    
    results(ws).T_window = T_window;
    results(ws).win_center = win_center(1:idx-1);
    results(ws).f_est = f_est(1:idx-1);
    results(ws).f_error = results(ws).f_est - f0;
end

figure('Name','Signal and Frequency Estimates','Position',[100 100 1000 800]);

subplot(3,1,1);
plot(t*1000, v, 'b', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Voltage (V)');
title('Input Signal v(t) with 15% Amplitude Step and Harmonics');
grid on;

subplot(3,1,2);
plot(results(1).win_center*1000, results(1).f_est, 'r', 'LineWidth',1.5); hold on;
yline(f0, 'k--', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
legend('Estimated f','True f','Location','best');
title('Frequency Estimate using 10 ms Window');
grid on;

subplot(3,1,3);
plot(results(2).win_center*1000, results(2).f_est, 'm', 'LineWidth',1.5); hold on;
yline(f0, 'k--', 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
legend('Estimated f','True f','Location','best');
title('Frequency Estimate using 20 ms Window');
grid on;
