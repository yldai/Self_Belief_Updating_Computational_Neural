%% Data simulation and parameter recovery with varying SNR
% Please make sure that VBA-toolbox-master has been added to the MATLAB path.

% VBA toolbox downloaded from https://mbb-team.github.io/VBA-toolbox/download/.

% This script is not designed to be run indepedently. It's called by 'SNR_loop.m', which tests 
% model performance across a range of signal-to-noise ratios (SNRs).

% For each SNR, simulated and recovered (inferred) parameter values are collected.
% Root mean squared error (RMSE) is then computed to quantify the accuracy of parameter recovery
% as a function of SNR.


function [posterior, out, a, b] = beliefupdating_simrecover_SNRvar(SNR)
% simulate input
    N = 40;
    BR = rand(N,1)*100;
    E1 = rand(N,1)*100;
    V = 2*randi([0,1],N,1)-1;  
    inputs = [BR, E1, V]';
    theta = [0.7; 0.1];
    a = theta(1);
    b = theta(2);
% simulate noiseless y
    y_clean = generative_model([], theta, inputs, []);
    E2_var = var(y_clean);
% define noise precision (1/var(noise))
    sigma2 = SNR / E2_var;
% save simulated data if needed
    save('data_SNRvar.mat', 'y_clean', 'E1', 'BR', 'V', 'a', 'b', 'E2_var');
%% Self belief updating generative model
    function [gx] = generative_model(~, theta, inputs, ~)
        BR = inputs(1,:);
        E1 = inputs(2,:);
        V  = inputs(3,:);
        a  = theta(1);
        b  = theta(2);
        sign_EE = (BR - E1) ./ abs(BR - E1);
        News = sign_EE .* V;
        LR = a + News .* b;
        E2 = E1 + LR .* (BR - E1);
        E2(isnan(E2)) = E1(isnan(E2));
        gx = E2;
    end
%% Simulation
    y = VBA_simulate(N, [], @generative_model, [], theta, inputs, Inf, sigma2, struct, []);
%% Model inversion
% specify dimensions
    dim.n_phi = 2;
    dim.u = 3;
    dim.p = 1;
    options.priors.muPhi = [1; 0];
    options.priors.SigmaPhi = diag([0.1, 0.1]);
% call inversion procedure
    [posterior, out] = VBA_NLStateSpaceModel(y, inputs, [], @generative_model, dim, options);
end
