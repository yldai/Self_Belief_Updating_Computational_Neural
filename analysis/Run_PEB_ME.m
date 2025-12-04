%% Parametric Empirical Bayes (PEB), Model 1

% This script reproduces the model 1 effective connectivity results
% reported in the Dai et al. manuscript (Figure 3, Table 2).

% -----------------------------------------------------------------------
% Please ensure that your SPM12 folder (r7771) is listed in your MATLAB set
% path. These results were obtained using Matlab R2023a. Values may
% slightly differ from the manuscript depending on OS and Matlab version.
% -----------------------------------------------------------------------

% This section runs a PEB model quantifying the between-subject commonality
% in connectivity parameters across the sample, and update magnitude associated
% variance in connectivity parameter strengths. The design matrix included
% an intercept term (single column of ones) denoting the overall mean
% connectivity and a regressor (single column of update magnitude (proportion of
% estimation error corrected) for each participant) denoting the connectivity variance.
clear

% Load GCM
load('/data/projects/punim1864/yingliang/spartan_scripts/DCM_scripts/specify/est_infer/GCM_controls_all.mat');

% PEB specification (load prepared design matrix)
load('M_Controls_ME.mat');
X = dm.X;
K = width(X);
X(:,2:K)=X(:,2:K)-mean(X(:,2:K));
X_labels = dm.labels;

M = struct();
M.Q = 'fields';
M.X = X;
M.Xnames = X_labels;

% PEB model estimation (select DCM parameters to take to 2nd level)
[PEB, RCM] = spm_dcm_peb(DCM, M, {'A','B'});
save('/data/projects/punim1864/yingliang/spartan_scripts/DCM_scripts/specify/est_infer/PEB_AB_all_ME.mat', 'PEB', 'RCM');

% PEB model comparison (automatic search over reduced PEB models)
BMA = spm_dcm_peb_bmc(PEB);
save('/data/projects/punim1864/yingliang/spartan_scripts/DCM_scripts/specify/est_infer/BMA_search_AB_all_ME.mat', 'BMA');

% Review BMA
spm_dcm_peb_review(BMA, DCM);
