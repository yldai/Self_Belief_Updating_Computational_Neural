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
% Three other regressors, including favorable v. unfavorable trial-wise estimation
% error magnitudes ratio and trial numbers ratio, as well as age, were also included to 
% account for potential confounds. 
clear
close all

% Load GCM & design matrix
load('../data/GCM_controls_all.mat');
load('../dm/M_Controls_ME_new.mat');

% PEB specification (load prepared design matrix)
X = dm.X;
K = width(X);
X(:,2:K)=X(:,2:K)-mean(X(:,2:K));
X_labels = dm.labels;

M = struct();
M.Q = 'fields';
M.X = X;
M.Xnames = X_labels;

% Hierarchical (PEB) inversion of DCMs using BMR and Variational Laplace
[PEB, RCM] = spm_dcm_peb(DCM, M, {'A','B'});

% Hierarchical (PEB) model comparison and averaging
BMA = spm_dcm_peb_bmc(PEB);

% Review BMA results
% -----------------------------------------------------------------------
% Second-level effect - overall self-belief updating (Table 2)
%   Threshold: Free energy, Strong evidence (Pp>.95)
%   Display as matrix: 
%     1) A-matrix (endogenous connectivity)
%     2) B-matrix (modulatory connectivity; Please select - Second-level effect - 
%        Mean for average modulatory effects and ME for update magnitude associated
%        variance in connectivity; input up)
% -----------------------------------------------------------------------
spm_dcm_peb_review(BMA, DCM)
