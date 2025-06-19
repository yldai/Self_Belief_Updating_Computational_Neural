%% Data simulation and parameter recovery for model testing
% Please make sure that VBA-toolbox-master has been added to the MATLAB path.

% VBA toolbox downloaded from https://mbb-team.github.io/VBA-toolbox/download/.

% This function could be run standalone or called using 'beliefupdating_abplot.m'.
% When it's run independently, simulation-recovery analysis will be performed for one time,
% yielding simulated and recovered parameter values and posterior distributions as well as log
% evidence to examine the reliability of parameter recovery. 
% When called using 'beliefupdating_abplot.m', this simulation-recovery analysis will be 
% performed repeatedly for the specified times. 

% Line 100-122 create figures shown in Supplementary Figure 3, illustrating noise distribution and 
%noise magnitude in relation to noiseless and noisy E2. Please uncomment these lines to execute. 

% To perform simulation for different parameter permutations - with b fixed to zero or negative b - 
% line 25 to 'theta=[VBA_random('Gaussian',0.7,0.04,1); 0];' for b=0, 
% 'theta=[VBA_random('Gaussian',0.7,0.04,1); VBA_random('Gaussian',-0.3,0.01,1)];' for b<0.

function [posterior, out] = beliefupdating_simrecover()
% simulate input variables
N = 40;
BR = rand(N,1)*100;
E1 = rand(N,1)*100;
V = 2*randi([0,1],N,1)-1;  
inputs = [BR, E1, V]';
% simulate parameters
theta=[VBA_random('Gaussian',0.7,0.04,1); VBA_random('Gaussian',0.1,0.01,1)]; 
a=theta(1);
b=theta(2);
% prepare for noise calculation
y_clean = generative_model([], theta, inputs, []);
E2_var = var(y_clean);
SNR =40;  
sigma2 = SNR/E2_var;  
% save data for correlational analysis of simulated and recovered parameters
save('sim_data.mat', 'y_clean', 'E1', 'BR', 'V', 'a', 'b', 'E2_var');

%% Self belief updating generative model
function [gx]=generative_model(~, theta, inputs, ~) 
    BR=inputs(1,:);
    E1=inputs(2,:);
    V=inputs(3,:);
    a=theta(1);
    b=theta(2);
  
    % Define sign_EE here
    % ---------------------------------------------------------------
    sign_EE=(BR - E1) ./ abs(BR - E1);
    % ---------------------------------------------------------------
    % Define news here
    % ---------------------------------------------------------------
    % When others are doing better than me in self rating of a positive word (higher rating
    % than me), the theoretical update direction will be to increase the rating (I should be
    % better). When others are doing worse than me for a positive word (lower rating than me),
    % the theoretical update direction will be to decrease the rating (I should be worse)
    
    % Should be vise versa for negative words, so sign_EE * V is used to adjust the news valence 
    % based on word valence.
    % ----------------------------------------------------------------
    News = sign_EE .* V;
    % ----------------------------------------------------------------
    % define learning rate here
    % ----------------------------------------------------------------
    % LRothers_better = a + b,
    % LRothers_worse = a - b
    % ----------------------------------------------------------------
    LR= a + News .* b;
    % Define E2 here
    % ----------------------------------------------------------------
    E2 = E1 + LR .* (BR - E1); 
    E2(isnan(E2)) = E1(isnan(E2)); % Address the nan by the end
    % Define output here
    % ----------------------------------------------------------------
    gx = E2;
end
%% Simulate data

% Adding noise in data simulation to demonstrate that with noise, ground truth could be recovered

%Inf is passed for the evolution noise variance since the hidden state is uninformative or irrelevant

[y] = VBA_simulate(N, [], @generative_model, [], theta, inputs, Inf, sigma2, struct, []);

%% Model inversion

% define dimensions
dim.n_phi = 2; % number of observation parameters (a and b)
dim.u = 3; % number of inputs (E1,BR and V)
dim.p = 1; % number of outputs (E2)

% define priors
options.priors.muPhi = [1; 0];
options.priors.SigmaPhi = diag([0.1, 0.1]); 

% call inversion function
[posterior, out] = VBA_NLStateSpaceModel(y, inputs, [], @generative_model, dim, options);

y_noise = y - y_clean; 
%% use these lines when running this function standalone to plot noise distribution and magnitude
%save('sim_noise.mat', 'y_noise','y','y_clean');
%figure;
%histogram(y_noise, 'Normalization', 'pdf', 'FaceColor', 'b', 'EdgeColor', 'k','NumBins', 20);
%hold on;
%mu = mean(y_noise);
%sigma = std(y_noise);
%x_vals = linspace(min(y_noise), max(y_noise), 100);
%y_vals = normpdf(x_vals, mu, sigma);
%plot(x_vals, y_vals, 'r-', 'LineWidth', 1.5);
%xlabel('Signal magnitude');
%ylabel('Probability density');
%legend('Noise magnitude', 'Distribution');
%set(gca, 'FontSize', 11);
%box off;
%figure;
%plot(y_clean, 'b', 'LineWidth', 1.5); hold on;
%plot(y, 'r:', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'MarkerSize', 3);
%plot(y_noise, 'g--', 'LineWidth', 1);
%xlabel('Observation point');
%ylabel('Signal magnitude');
%legend('E2 without noise', 'E2 with noise', 'Noise data');
%hold off;
%% calculate actual SNR to make sure it's correctly incorporated in the simulate-recovery analysis
actual_SNR = var(y_clean) / var(y_noise);
fprintf('Actual SNR: %.2f (Target SNR=%.2f)\n', actual_SNR, SNR);

end

