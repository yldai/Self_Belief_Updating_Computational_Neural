%% Inverting full self belief updating biased model and reduced model to obtain Bayes log evidences
% Please make sure that VBA-toolbox-master has been added to the MATLAB path.

% VBA toolbox downloaded from https://mbb-team.github.io/VBA-toolbox/download/.

% This script iteratively invert the full model and the reduced models to each participant through 
% selectively fixing prior mean and covariance to zero and performing VBA_NLStateSpaceModel function 
% using different parameter permutations. Posterior distributions and Bayesian log model evidences (i.e. free energy 
% approximation) across the four models were combined and saved for variational Bayesian Model Comparison.


function beliefupdating_modelcomparison()
% Read participant files and initiate data structures to store outputs
subject_ids = {'100','101','102'...,'200'}; % modify as needed
n_subjects = length(subject);
n_models = 4;
F_values_matrix = zeros(n_models, n_subjects);
posterior_all = cell(n_models, n_subjects);
out_all = cell(n_models, n_subjects);

for s = 1:n_subjects
    subj_id = subject{s};
    filename = ['/Users/Desktop/behavioral_results/controls/' subj_id '_linearmodel_all.csv'];
    % specify input variables
    data = readtable(filename);
    N = 40;
    BR = data.base_rate; 
    E1 = data.parpre_rate; 
    valenceStr = string(data.valence); 
    V = ones(size(valenceStr)); 
    V(valenceStr ~= "p") = -1; 
    y = data.slider_score';
    inputs = [E1, BR, V]';

    
    %specify priors - full model with a and b switched on     
    options1.priors.muPhi = [1; 0]; 
    options1.priors.SigmaPhi = diag([0.1, 0.1]); 
    %specify priors - reduced model with a switched on and b switched off  
    options2.priors.muPhi = [1; 0]; 
    options2.priors.SigmaPhi = diag([0.1, 0]); 
    %specify priors - reduced model with a switched off and b switched on  
    options3.priors.muPhi = [0; 0];
    options3.priors.SigmaPhi = diag([0, 0.1]);
    %specify priors - reduced model with a and b switched off  
    options4.priors.muPhi = [0; 0];
    options4.priors.SigmaPhi = diag([0, 0]);

   
    % specify model dimensions
    dim.n_phi = 2; % Number of parameters to estimate (a, b)
    dim.u = 3; % Number of input variables (E1, BR, V)
    dim.p = 1; % One observed value per trial (y)

    % Perform model inversion
    [posterior1, out1] = VBA_NLStateSpaceModel(y, inputs, [], @generative_model, dim, options1);
    [posterior2, out2] = VBA_NLStateSpaceModel(y, inputs, [], @generative_model, dim, options2);
    [posterior3, out3] = VBA_NLStateSpaceModel(y, inputs, [], @generative_model, dim, options3);
    [posterior4, out4] = VBA_NLStateSpaceModel(y, inputs, [], @generative_model, dim, options4);
    
    % Compile posteriors across models 
    posterior_all(:, s) = {posterior1; posterior2; posterior3; posterior4};
    out_all(:, s) = {out1; out2; out3; out4};
    % Compile log evidences across models
    F_values_matrix(:, s) = [out1.F; out2.F; out3.F; out4.F];
    fprintf('\nSubject %s\n', subj_id);
    fprintf('  Model 1 (a+b): %.2f\n', out1.F);
    fprintf('  Model 2 (a only): %.2f\n', out2.F);
    fprintf('  Model 3 (b only): %.2f\n', out3.F);
    fprintf('  Model 4 (E1 only): %.2f\n', out4.F);
end
    % Save outputs
    save('F_values_matrix.mat', 'F_values_matrix');
    save('posterior_4models.mat', 'posterior_all');
    save('out_4models.mat', 'out_all');

end
%% Self Belief Updating Generative Model     
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
