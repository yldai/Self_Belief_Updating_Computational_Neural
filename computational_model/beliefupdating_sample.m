%% Data simulation and parameter recovery 
% Please make sure that VBA-toolbox-master has been added to the MATLAB path.

% VBA toolbox downloaded from https://mbb-team.github.io/VBA-toolbox/download/.

% This script is adapted from 'beliefupdating_simrecover.m' and was used to generate Supplementary 
% Figure 5a, b, c & d. BR and E1 were semi-randomly sampled, V was pseudo-randomly sampled.

% To replicate the findings, modify line 23 (theta assignment) as follows:
% For Figure 5a (a = 0.5, b = 0):     theta = [0.5; 0];
% For Figure 5b (a = 0.5, b = -0.2):  theta = [0.5; -0.2];
% For Figure 5c (a = 0, b = 0.2):     theta = [0; 0.2];
% For Figure 5d (a = 0, b = 0):       theta = [0; 0];
 
% simulate input variables
function [posterior, out] = beliefupdating_sample()
    N = 40;
    BR = 60 + (90 - 60) * rand(N, 1); 
    E1 = 20 + (40 - 10) * rand(N, 1);  
    V = repmat([1; -1], N/2, 1);       
    inputs = [BR, E1, V]';
    % simulate parameters
    theta = [0.5; 0]; 
    sign_EE = (BR - E1) ./ abs(BR - E1);
    News = sign_EE .* V;
    % prepare for noise calculation
    y_clean = generative_model([], theta, inputs, []);
    E2_var = var(y_clean);
    SNR = 40;
    sigma2 = SNR / E2_var; 
    %% Simulate data
    [y] = VBA_simulate(N, [], @generative_model, [], theta, inputs, Inf, sigma2, struct, []);
    
   %% Model inversion

    % define dimensions 
    dim.n_phi = 2;
    dim.u = 3;
    dim.p = 1;
    % define priors
    options.priors.muPhi = [1; 0];
    options.priors.SigmaPhi = diag([0.1, 0.1]); 

    % call inversion function
    [posterior, out] = VBA_NLStateSpaceModel(y, inputs, [], @generative_model, dim, options); 

    y_noise = y - y_clean; 
    save('noise_model1.mat', 'y_noise', 'y', 'y_clean','E1', 'BR', 'E1', 'BR', 'theta');
  
%% Visualization 
    news_y = zeros(N, 1); 
    news_color = zeros(N, 3);  
    news_y2 = zeros(N, 1);
    news_color2 = zeros(N, 3);
% visualize favorable & unfavorable valence
    for t = 1:N
     if News(t) == 1 
          news_y(t) = 100;
          news_color(t, :) = [0, 0.5, 0];  
     else 
          news_y(t) = 100;
          news_color(t, :) = [0.8, 0, 0];  
     end
    end
% visualize word valence
    for t = 1:N
      if V(t) == 1  
         news_y2(t) = 0;
         news_color2(t, :) = [0.8, 0.5, 0];  
      else 
         news_y2(t) = 0;
         news_color2(t, :) = [0, 0, 1];  
      end
    end
%% plot noise distribution and magnitude
    figure;
    histogram(y_noise, 'Normalization', 'pdf', 'FaceColor', 'b', 'EdgeColor', 'k','NumBins', 20);
    hold on;
    mu = mean(y_noise);
    sigma = std(y_noise);
    x_vals = linspace(min(y_noise), max(y_noise), 100);
    y_vals = normpdf(x_vals, mu, sigma);
    plot(x_vals, y_vals, 'r-', 'LineWidth', 1.5);
    xlabel('Signal magnitude');
    ylabel('Probability density');
    legend('Noise magnitude', 'Distribution');
    set(gca, 'FontSize', 11);
    box off;
    figure;
    plot(y_clean, '-s', 'Color', [1.0 0.8 0.1], 'LineWidth', 1.1, 'MarkerSize', 3); hold on;
    plot(y, ':', 'Color', [1.0 0.8 0.1], 'LineWidth', 1.1, 'MarkerFaceColor', [1.0 0.8 0.1], 'MarkerSize', 3);
    plot(E1, '-s', 'Color', [0.6 0.8 1.0], 'LineWidth', 1.1, ...
    'MarkerFaceColor', [0.6 0.8 1.0], 'MarkerSize', 3);
    plot(BR, '-s', 'Color', [0.8 0.2 0.2], 'LineWidth', 1.1, ...
    'MarkerFaceColor', [0.8 0.2 0.2], 'MarkerSize', 3);
    plot(y_noise, 'g--', 'LineWidth', 1);
    scatter(1:N, news_y, 10, news_color, 'filled', 'DisplayName', 'Favorable');
    scatter(1:N, news_y2, 10, news_color2, 'filled', 'DisplayName', 'Positive word');
    xlabel('Observation point');
    ylabel('Signal magnitude');
    legend('E2 without noise', 'E2 with noise', 'Noise data');
  
    %% compute noise mean and sd if needed
    fprintf('Standard error of noise: %.4f\n', std(y_noise(:)));
    fprintf('Mean of noise: %.4f\n', mean(y_noise(:)));
    fprintf('Variance of noise: %.1f\n',std(y_noise(:).^2));
end

%% Self belief updating generative model 
function [gx] = generative_model(~, theta, inputs, ~)
    BR = inputs(1,:);
    E1 = inputs(2,:);
    V = inputs(3,:);
    a = theta(1);
    b = theta(2);
    sign_EE = (BR - E1) ./ abs(BR - E1);
    News = sign_EE .* V;
    LR= a + News .* b;
    E2 = E1 + LR .* (BR - E1); 
    E2(isnan(E2)) = E1(isnan(E2));
    gx = E2;
end