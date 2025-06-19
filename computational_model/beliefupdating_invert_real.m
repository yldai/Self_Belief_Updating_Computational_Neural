%% Model inversion at subject level and Bayesian model avearging at group level
% Please make sure that VBA-toolbox-master has been added to the MATLAB path.

% VBA toolbox downloaded from https://mbb-team.github.io/VBA-toolbox/download/.

% Self belief updating generative model specified towards the end of script.

% This script is used to perform self belief updating generative model inversion to a single participant.
% Through inverting the model at subject level, posterior distributions of parameters, posterior probabilities
% and Bayesian log model evidence are estimated and visualized via built in functions of VBA.

function [posterior,out] = beliefupdating_invert_real()
% load participant file
    data=readtable('/Users/Desktop/behavioral_results/controls/100_linearmodel_all.csv');
    % define input variables
    N = 40;
    BR = data.base_rate; 
    E1 = data.parpre_rate; 
    valenceStr = string(data.valence); 
    V = ones(size(valenceStr)); 
    V(valenceStr ~= "p") = -1; 
    inputs = [E1, BR, V]';
    y = data.slider_score';
    % define priors
    options.priors.muPhi = [1; 0];
    options.priors.SigmaPhi = diag([0.1, 0.1]);
    % define model dimensions
    dim.n_phi = 2; % Number of parameters to estimate (a, b)
    dim.u = 3; % Number of input variables (E1, BR, V)
    dim.p = 1; % One observed value per trial (y)
    % call inversion function
    [posterior, out] = VBA_NLStateSpaceModel(y, inputs, [], @generative_model, dim, options);
    % print out free energy approximation (i.e. low bound of Bayesian log model evidence
    fprintf('Free energy approximation: %.2f\n', out.F);
    % print out model fit if needed
    fprintf('Percentage of explained variance (R2): %03.2f\n', out.fit.R2);
    
  
end
%% Self belief updating generative model
function [gx] = generative_model(~, theta, inputs, ~)
    BR=inputs(1,:);
    E1=inputs(2,:);
    V=inputs(3,:);
    % Define sign_EE here
    % ---------------------------------------------------------------
    sign_EE=(BR - E1) ./ abs(BR - E1);
    % ---------------------------------------------------------------
    % Define conditions here
    % Favorable or unfavorable casted by sign of EE and word valence V
    % ----------------------------------------------------------------
    News = sign_EE .* V;
    % ----------------------------------------------------------------
    % define learning rate here
    % ----------------------------------------------------------------
    % LRfavorable = a + b,
    % LRunfavorable = a - b
    LR = theta(1) + News .* theta(2);
    % ----------------------------------------------------------------
    % Define E2 here
    % ----------------------------------------------------------------
    E2 = E1 + LR .* (BR - E1); 
    E2(isnan(E2)) = E1(isnan(E2)); % Address the nan by the end
    % Define output here
    % ----------------------------------------------------------------
    gx = E2;
end
