function y = upd_model(~, P, u, ~)
% =========================================================================
% Observation function for a simple belief-updating model, designed for use
% with VBA_simulate and VBA_NLStateSpaceModel.
% This model assumes that the baseline learning parameter a scales with
% estimation error - baseline learning rate is higher when estimation error
% magnitude increases, regardless of valance.
%
% Model:
%   N  = sign(BR - E1) * V
%   LR = (abs(BR - E1)/5) * exp(a) + N * exp(b)
%   y  = E1 + LR * (BR - E1)
%
% AUTHOR / DATE
%   Matthew D. Greaves, University of Melbourne; adapted by Yingliang Dai,
% University of Melbourne.
%   Last updated: 25/06/2026.
% =========================================================================

% --- Unpack inputs -------------------------------------------------------
BR  = u(1);      % Base rate
E1  = u(2);      % Initial estimate
V   = u(3);      % Stimulus valence

% --- Unpack parameters ---------------------------------------------------
a   = P(1);       % Learning rate intercept
b   = P(2);       % Learning rate bias

% --- Compute valence-weighted learning rate ------------------------------
N   = sign(BR - E1) * V;    % Feedback valence
LR  = (abs(BR - E1)/5) * exp(a) + N * exp(b);  % Effective learning rate

% --- Update estimate -----------------------------------------------------
y   = E1 + LR * (BR - E1);  % Updated estimate (scalar)

end
