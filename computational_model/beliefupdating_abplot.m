%% Data simulation and parameter recovery for model testing
% Please make sure that VBA-toolbox-master has been added to the MATLAB path.

% VBA toolbox downloaded from https://mbb-team.github.io/VBA-toolbox/download/.

% This script calls 'beliefupdating_simrecover.m' and iteratively perform simulation-recovery analysis with 
% randomly simulated parameters a and b.
% Simulated and recovered (inferred) parameter values from each iteration will be aggregated and compared,
% with pearson's correlation coefficient (R) and root mean squared error (RMSE) computed to quantify accuracy
% of parameter recovery. 

% To perform simulation for different parameter permutations - with b fixed to zero or negative b - 
% change line 25 in 'beliefupdating_simrecover' to 'theta=[VBA_random('Gaussian',0.7,0.04,1); 0];' for b=0, 
% 'theta=[VBA_random('Gaussian',0.7,0.04,1); VBA_random('Gaussian',-0.3,0.01,1)];' for b<0.

% specify interation times
n_iter = 50;
% store parameter and R2 values
true_a = zeros(n_iter, 1);
true_b = zeros(n_iter, 1);
est_a  = zeros(n_iter, 1);
est_b  = zeros(n_iter, 1);
R2     = zeros(n_iter, 1);

for i = 1:n_iter
    fprintf('\nIteration %d\n', i);
    [posterior, out] = beliefupdating_simrecover();

    true_params = load('sim_data.mat');  

    true_a(i) = true_params.a;
    true_b(i) = true_params.b;

    est_a(i) = posterior.muPhi(1);
    est_b(i) = posterior.muPhi(2);

    R2(i) = out.fit.R2;
end

% Compute RMSE and r for both parameters
rmse_a = sqrt(mean((true_a - est_a).^2));
rmse_b = sqrt(mean((true_b - est_b).^2));

[r_a, p_a] = corr(true_a, est_a);
[r_b, p_b] = corr(true_b, est_b);
% print the values of r and RMSW
fprintf('a: r = %.2f, RMSE = %.3f\n', r_a, rmse_a);
fprintf('b: r = %.2f, RMSE = %.3f\n', r_b, rmse_b);

%% Parity plot for a and b
figure;
scatter(true_a, est_a, 60, 'filled');
hold on; plot([0 1], [0 1], 'k-'); 
xlabel('True a', 'FontSize', 15); ylabel('Estimated a', 'FontSize', 15);
% add r and RMSE in title if needed
%title(sprintf('a: r=%.2f, RMSE=%.3f', r_a, rmse_a)); 
set(gca, 'FontSize', 15);
grid on;

figure;
scatter(true_b, est_b, 60, 'filled');
hold on; plot([0 0.2], [0 0.2], 'k-'); 
xlabel('True b', 'FontSize', 15); ylabel('Estimated b', 'FontSize', 15);
% add r and RMSE in title if needed
%title(sprintf('b: r=%.2f, RMSE=%.3f', r_b, rmse_b)); 
set(gca, 'FontSize', 15);
grid on;

%% Kernel density distribution - parameter a
figure; hold on;
% density estimation
[x1, f1] = ksdensity(true_a);
[x2, f2] = ksdensity(est_a);

% define colors
c_fill_true = [0 0 1];  
c_fill_est  = [1 0 0];  

% Plot simulated a
plot(f1, x1, '-', 'Color', c_fill_true, 'LineWidth', 2);

% Plot recovered (inferred) a
plot(f2, x2, '-', 'Color', c_fill_est, 'LineWidth', 2);

xlabel('Parameter a value');
ylabel('Probability density');
legend('True a', 'Estimated a', 'Location', 'best');
set(gca, 'FontSize', 20, 'LineWidth', 1.5);
box on;

%% Kernel density distribution - parameter b
figure; hold on;

% density estimation
[x1b, f1b] = ksdensity(true_b);
[x2b, f2b] = ksdensity(est_b);

% Plot simulated b
plot(f1b, x1b, '-', 'Color', c_fill_true, 'LineWidth', 2);

% Plot recovered (inferred) b
plot(f2b, x2b, '-', 'Color', c_fill_est, 'LineWidth', 2);

xlabel('Parameter b value');
ylabel('Probability density');
legend('True b', 'Estimated b', 'Location', 'best');
set(gca, 'FontSize', 20, 'LineWidth', 1.5);
box on;
