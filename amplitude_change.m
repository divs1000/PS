clear; clc; close all;

Fs      = 1600;               % Sampling frequency (Hz)
Ts      = 1/Fs;
T_end   = 0.3;                % Total simulation time (s)
t       = 0:Ts:T_end-Ts;      % Time vector
N_total = length(t);

f0      = 50;                 % True fundamental frequency
A1 = 230;                     % Initial amplitude
step_time = 0.15;             % Time of amplitude step (s)
A2 = A1 * 1.15;               % 15% amplitude increase

% Build time-varying amplitude profile
A = A1 * ones(size(t));
A(t >= step_time) = A2;

% Signal with selected harmonics
h3_fraction = 0.10;   phase3 = pi/6;
h5_fraction = 0.05;   phase5 = -pi/8;
v = A .* sin(2*pi*f0*t) ...                       % fundamental
    + (h3_fraction * A) .* sin(2*pi*5*f0*t + phase3) ...  % 5th harmonic
    + (h5_fraction * A) .* sin(2*pi*7*f0*t + phase5);     % 7th harmonic

window_sizes    = [0.01, 0.02];    % Sliding window lengths (s)
f_candidates    = 48.5:0.01:51.5;   % Frequency grid for search
allowed_harmonics = [1,5,7,11,13];
step_size       = 1;               % Slide by one sample

results = struct();
for ws = 1:length(window_sizes)
    T_window   = window_sizes(ws);
    N_window   = round(T_window * Fs);   % Samples per window
    num_est     = N_total - N_window + 1;

    f_est       = zeros(num_est,1);
    win_center  = zeros(num_est,1);

    idx = 1;
    while (idx + N_window - 1) <= N_total
        idx_win = idx:(idx + N_window - 1);
        t_win   = t(idx_win);
        v_win   = v(idx_win);

        % Least-squares fit over harmonics at each candidate freq
        SSE = zeros(size(f_candidates));
        for iF = 1:length(f_candidates)
            f_test = f_candidates(iF);
            M = [];
            for hh = allowed_harmonics
                M = [M, sin(2*pi*f_test*hh*t_win(:)), cos(2*pi*f_test*hh*t_win(:))];
            end
            a_hat      = (M'*M) \ (M'*v_win(:));
            v_fit      = M * a_hat;
            err        = v_win(:) - v_fit;
            SSE(iF)    = sum(err.^2);
        end

        [~, idx_min]     = min(SSE);
        f_est(idx)       = f_candidates(idx_min);
        win_center(idx)  = t_win(end) + Ts;  % Center time of this window

        idx = idx + step_size;  % Slide window by one sample
    end

    results(ws).T_window   = T_window;
    results(ws).win_center = win_center(1:idx-1);
    results(ws).f_est      = f_est(1:idx-1);
    results(ws).f_error    = results(ws).f_est - f0;
end

% Plot input and sliding-window frequency estimates
figure('Name','Signal and Frequency Estimates','Position',[100 100 1000 800]);

subplot(3,1,1);
plot(t*1000, v, 'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Voltage (V)');
title('Input Signal with Amplitude Step + Harmonics');
grid on;

subplot(3,1,2);
plot(results(1).win_center*1000, results(1).f_est, 'LineWidth',1.5); hold on;
yline(f0, 'k--','LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
title('Estimate via 10 ms Sliding Window');
grid on;

subplot(3,1,3);
plot(results(2).win_center*1000, results(2).f_est, 'LineWidth',1.5); hold on;
yline(f0, 'k--','LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
title('Estimate via 20 ms Sliding Window');
grid on;


