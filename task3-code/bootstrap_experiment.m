clear;
clc;
close all;

% Reproducible random seed
rng(42, 'twister');

% Parameters
N = 10;    % Original sample size
M = 1000;  % Number of bootstrap resamples

fprintf('Parameters: N = %d (original sample size), M = %d (bootstrap rounds)\n', N, M);

% Generate N samples from standard normal N(0,1)
original_data = randn(N, 1);

fprintf('Original samples (N=%d):\n', N);
fprintf('%s\n', repmat('-', 1, 45));
for i = 1:N
    fprintf('  x[%2d] = %+0.4f\n', i, original_data(i));
end
fprintf('%s\n', repmat('-', 1, 45));
fprintf('  Sample mean   : %0.4f\n', mean(original_data));
fprintf('  Sample var    : %0.4f\n', var(original_data, 1));
fprintf('  Sample std    : %0.4f\n', std(original_data, 1));

% Storage for bootstrap sample statistics
bootstrap_means = zeros(M, 1);
bootstrap_vars = zeros(M, 1);

% Bootstrap resampling (sampling with replacement)
for i = 1:M
    idx = randi(N, N, 1);
    bootstrap_sample = original_data(idx);
    bootstrap_means(i) = mean(bootstrap_sample);
    bootstrap_vars(i) = var(bootstrap_sample, 1); % Match numpy var(ddof=0)
end

fprintf('Bootstrap sampling finished. Generated %d bootstrap samples.\n', M);

% Aggregate statistics from bootstrap results
mean_of_means = mean(bootstrap_means);
var_of_means = var(bootstrap_means, 1);
std_of_means = std(bootstrap_means, 1);

mean_of_vars = mean(bootstrap_vars);
var_of_vars = var(bootstrap_vars, 1);
std_of_vars = std(bootstrap_vars, 1);

fprintf('%s\n', repmat('=', 1, 50));
fprintf('        Bootstrap Statistics Summary\n');
fprintf('%s\n\n', repmat('=', 1, 50));
fprintf('Original sample (N=%d)\n', N);
fprintf('  Mean = %0.6f\n', mean(original_data));
fprintf('  Var  = %0.6f\n\n', var(original_data, 1));

fprintf('Distribution of bootstrap means (M=%d)\n', M);
fprintf('  Mean of means = %0.6f\n', mean_of_means);
fprintf('  Var of means  = %0.6f\n', var_of_means);
fprintf('  Std of means  = %0.6f\n\n', std_of_means);

fprintf('Distribution of bootstrap variances (M=%d)\n', M);
fprintf('  Mean of vars  = %0.6f\n', mean_of_vars);
fprintf('  Var of vars   = %0.6f\n', var_of_vars);
fprintf('  Std of vars   = %0.6f\n\n', std_of_vars);

fprintf('Theoretical references for standard normal\n');
fprintf('  Population mean = 0.000000\n');
fprintf('  Population var  = 1.000000\n');
fprintf('  Mean StdErr (theory) = 1/sqrt(N) = %0.6f\n', 1 / sqrt(N));
fprintf('%s\n', repmat('=', 1, 50));

% Colors
c_hist = [0.298, 0.447, 0.690];
c_kde = [0.867, 0.518, 0.322];
c_line = [0.769, 0.306, 0.322];
c_orig = [0.173, 0.627, 0.173];
c_var = [0.333, 0.659, 0.408];
c_purple = [0.494, 0.184, 0.556];

% Figure 1: 2x2 summary plots
fig1 = figure('Position', [100, 80, 1400, 1000]);
sgtitle(sprintf('Bootstrap Method Experiment (N=%d, M=%d)', N, M), 'FontWeight', 'bold');

% Subplot 1: Original samples
subplot(2, 2, 1);
x_range = linspace(-4, 4, 300);
plot(x_range, normal_pdf(x_range, 0, 1), 'Color', c_line, 'LineWidth', 2, ...
    'DisplayName', 'Standard Normal N(0,1)');
hold on;
scatter(original_data, zeros(N, 1), 70, 'filled', ...
    'MarkerFaceColor', c_orig, 'DisplayName', sprintf('Original N=%d samples', N));
for i = 1:N
    xline(original_data(i), '-', 'Color', 0.6 * c_orig + 0.4, 'LineWidth', 1, 'HandleVisibility', 'off');
end
xline(mean(original_data), '--', 'Color', c_purple, 'LineWidth', 2, ...
    'DisplayName', sprintf('Sample mean = %.3f', mean(original_data)));
title(sprintf('Step 1: Original Sample (N=%d)', N), 'FontWeight', 'bold');
xlabel('Value');
ylabel('Density');
grid on;
legend('Location', 'best', 'FontSize', 8);

% Subplot 2: Bootstrap means distribution
subplot(2, 2, 2);
histogram(bootstrap_means, 40, 'Normalization', 'pdf', ...
    'FaceColor', c_hist, 'FaceAlpha', 0.7, 'EdgeColor', [1, 1, 1], ...
    'DisplayName', 'Bootstrap means');
hold on;
mu_fit = mean(bootstrap_means);
std_fit = std(bootstrap_means, 1);
x_fit = linspace(min(bootstrap_means), max(bootstrap_means), 200);
plot(x_fit, normal_pdf(x_fit, mu_fit, std_fit), 'Color', c_kde, 'LineWidth', 2.5, ...
    'DisplayName', sprintf('Fitted Normal (mu=%.3f, sigma=%.3f)', mu_fit, std_fit));
xline(mean_of_means, '--', 'Color', c_line, 'LineWidth', 2, ...
    'DisplayName', sprintf('Mean of means = %.3f', mean_of_means));
xline(0, ':', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1.5, 'DisplayName', 'True mean = 0');
title(sprintf('Bootstrap Means Distribution (M=%d)', M), 'FontWeight', 'bold');
xlabel('Bootstrap Sample Mean');
ylabel('Density');
grid on;
legend('Location', 'best', 'FontSize', 8);

% Subplot 3: Bootstrap variances distribution
subplot(2, 2, 3);
histogram(bootstrap_vars, 40, 'Normalization', 'pdf', ...
    'FaceColor', c_var, 'FaceAlpha', 0.7, 'EdgeColor', [1, 1, 1], ...
    'DisplayName', 'Bootstrap variances');
hold on;
mu_var = mean(bootstrap_vars);
std_var = std(bootstrap_vars, 1);
x_var = linspace(min(bootstrap_vars), max(bootstrap_vars), 200);
plot(x_var, normal_pdf(x_var, mu_var, std_var), 'Color', c_kde, 'LineWidth', 2.5, ...
    'DisplayName', sprintf('Fitted Normal (mu=%.3f, sigma=%.3f)', mu_var, std_var));
xline(mean_of_vars, '--', 'Color', c_line, 'LineWidth', 2, ...
    'DisplayName', sprintf('Mean of vars = %.3f', mean_of_vars));
xline(1.0, ':', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1.5, 'DisplayName', 'True variance = 1');
title(sprintf('Bootstrap Variances Distribution (M=%d)', M), 'FontWeight', 'bold');
xlabel('Bootstrap Sample Variance');
ylabel('Density');
grid on;
legend('Location', 'best', 'FontSize', 8);

% Subplot 4: Convergence curves
subplot(2, 2, 4);
steps = (1:M)';
cumulative_mean = cumsum(bootstrap_means) ./ steps;
cumulative_var = cumsum(bootstrap_vars) ./ steps;
plot(steps, cumulative_mean, 'Color', c_hist, 'LineWidth', 1.5, ...
    'DisplayName', 'Cumulative mean of means');
hold on;
plot(steps, cumulative_var, 'Color', c_var, 'LineWidth', 1.5, ...
    'DisplayName', 'Cumulative mean of variances');
yline(0, '--', 'Color', c_hist, 'LineWidth', 1, 'DisplayName', 'True mean = 0');
yline(1, '--', 'Color', c_var, 'LineWidth', 1, 'DisplayName', 'True variance = 1');
yline(mean(original_data), ':', 'Color', c_purple, 'LineWidth', 1, ...
    'DisplayName', sprintf('Sample mean = %.3f', mean(original_data)));
title('Convergence of Bootstrap Estimates', 'FontWeight', 'bold');
xlabel('Number of Bootstrap Samples');
ylabel('Cumulative Estimate');
xlim([1, M]);
grid on;
legend('Location', 'best', 'FontSize', 8);

% Save figure 1
result_dir = fullfile('result', 'matlab');
if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end
fig1_path = fullfile(result_dir, sprintf('bootstrap_result_N=%d_M=%d.png', N, M));
print(fig1, fig1_path, '-dpng', '-r300');
fprintf('Saved figure: %s\n', fig1_path);

% 95% percentile bootstrap confidence intervals
alpha = 0.05;
ci_mean_low = percentile_linear(bootstrap_means, 100 * alpha / 2);
ci_mean_high = percentile_linear(bootstrap_means, 100 * (1 - alpha / 2));
ci_var_low = percentile_linear(bootstrap_vars, 100 * alpha / 2);
ci_var_high = percentile_linear(bootstrap_vars, 100 * (1 - alpha / 2));

fprintf('%s\n', repmat('=', 1, 55));
fprintf('    Bootstrap 95%% Confidence Intervals (Percentile)\n');
fprintf('%s\n', repmat('=', 1, 55));
fprintf('  CI for population mean:     [%.4f, %.4f]\n', ci_mean_low, ci_mean_high);
fprintf('  CI for population variance: [%.4f, %.4f]\n\n', ci_var_low, ci_var_high);
fprintf('  True mean 0 inside CI? %s\n', yes_no(ci_mean_low <= 0 && 0 <= ci_mean_high));
fprintf('  True var  1 inside CI? %s\n', yes_no(ci_var_low <= 1 && 1 <= ci_var_high));
fprintf('%s\n', repmat('=', 1, 55));

% Analytical probability
prob_theory = (1 - 1 / N) ^ N;
prob_limit = exp(-1);

fprintf('%s\n', repmat('=', 1, 60));
fprintf('Probability a sample is never selected in one bootstrap draw\n');
fprintf('%s\n', repmat('=', 1, 60));
fprintf('  N            = %d\n', N);
fprintf('  (1-1/N)^N    = %.6f\n', prob_theory);
fprintf('  limit e^(-1) = %.6f\n', prob_limit);
fprintf('  abs diff     = %.6f\n\n', abs(prob_theory - prob_limit));

% Simulation for out-of-bag (OOB) probability
rng(42, 'twister');
never_seen_count = zeros(N, 1);
for t = 1:M
    indices = randi(N, N, 1);
    sampled_flag = false(N, 1);
    sampled_flag(indices) = true;
    never_seen_count = never_seen_count + ~sampled_flag;
end

never_seen_prob = never_seen_count / M;
empirical_mean = mean(never_seen_prob);

fprintf('  Simulation result (M=%d rounds):\n', M);
fprintf('   %8s  %15s  %12s\n', 'index', 'never selected', 'empirical p');
fprintf('   %s\n', repmat('-', 1, 42));
for j = 1:N
    fprintf('   %8d  %15d  %12.4f\n', j - 1, never_seen_count(j), never_seen_prob(j));
end
fprintf('   %s\n', repmat('-', 1, 42));
fprintf('   %8s  %15s  %12.4f\n\n', 'mean', '-', empirical_mean);
fprintf('  Theory (1-1/N)^N = %.4f\n', prob_theory);
fprintf('  Limit  e^(-1)    = %.4f\n', prob_limit);
fprintf('  Empirical mean   = %.4f\n', empirical_mean);
fprintf('%s\n', repmat('=', 1, 60));

% Figure 2: OOB verification
N_values = 1:200;
prob_curve = (1 - 1 ./ N_values) .^ N_values;

fig2 = figure('Position', [120, 120, 1400, 500]);
sgtitle(sprintf('OOB Probability Verification (N=%d, M=%d)', N, M), 'FontWeight', 'bold');

% Left: convergence of (1-1/N)^N to e^-1
subplot(1, 2, 1);
plot(N_values, prob_curve, 'Color', c_hist, 'LineWidth', 2, 'DisplayName', '(1-1/N)^N');
hold on;
yline(prob_limit, '--', 'Color', c_line, 'LineWidth', 1.8, ...
    'DisplayName', sprintf('Limit e^{-1} = %.4f', prob_limit));
xline(N, ':', 'Color', c_orig, 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Current N=%d, value=%.4f', N, prob_theory));
scatter(N, prob_theory, 80, 'filled', 'MarkerFaceColor', c_orig, 'HandleVisibility', 'off');
title('(1-1/N)^N Converges to e^{-1}');
xlabel('N (Sample Size)');
ylabel('Probability');
ylim([0, 0.5]);
grid on;
legend('Location', 'best', 'FontSize', 9);

% Right: empirical OOB probability for each sample
subplot(1, 2, 2);
bar(0:(N - 1), never_seen_prob, 'FaceColor', c_hist, 'FaceAlpha', 0.75, ...
    'DisplayName', 'Empirical Probability (Never Selected)');
hold on;
yline(prob_theory, '--', 'Color', c_kde, 'LineWidth', 2, ...
    'DisplayName', sprintf('Theory (1-1/N)^N = %.4f', prob_theory));
yline(prob_limit, ':', 'Color', c_line, 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Limit e^{-1} = %.4f', prob_limit));
yline(empirical_mean, '-.', 'Color', c_orig, 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Empirical Mean = %.4f', empirical_mean));
title(sprintf('Empirical OOB Probability (N=%d, M=%d)', N, M));
xlabel('Sample Index');
ylabel('Proportion Never Selected');
xticks(0:(N - 1));
grid on;
legend('Location', 'best', 'FontSize', 9);

% Save figure 2
oob_dir = fullfile('oob', 'matlab');
if ~exist(oob_dir, 'dir')
    mkdir(oob_dir);
end
fig2_path = fullfile(oob_dir, sprintf('bootstrap_oob_N%d_M%d.png', N, M));
print(fig2, fig2_path, '-dpng', '-r300');
fprintf('Saved figure: %s\n', fig2_path);


function y = normal_pdf(x, mu, sigma)
% Basic normal PDF to avoid toolbox dependency.
y = 1 ./ (sigma * sqrt(2 * pi)) .* exp(-0.5 * ((x - mu) ./ sigma) .^ 2);
end

function p = percentile_linear(x, q)
% Percentile with linear interpolation, q in [0, 100].
x = sort(x(:));
n = numel(x);
if n == 0
    p = NaN;
    return;
end
if q <= 0
    p = x(1);
    return;
end
if q >= 100
    p = x(end);
    return;
end

rank = (q / 100) * (n - 1) + 1;
lo = floor(rank);
hi = ceil(rank);
if lo == hi
    p = x(lo);
else
    w = rank - lo;
    p = x(lo) + w * (x(hi) - x(lo));
end
end

function s = yes_no(tf)
if tf
    s = 'YES';
else
    s = 'NO';
end
end
