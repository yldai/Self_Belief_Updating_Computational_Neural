%% Data simulation and parameter recovery with varying SNR
% Please make sure that VBA-toolbox-master has been added to the MATLAB path.

% VBA toolbox downloaded from https://mbb-team.github.io/VBA-toolbox/download/.

% This script calls 'beliefupdating_simrecover_SNRvar.m', which tests model performance
% across a range of signal-to-noise ratios (SNRs).

% For each SNR, simulated and recovered (inferred) parameter values are collected.
% Root mean squared error (RMSE) is then computed to quantify the accuracy of parameter recovery
% as a function of SNR.

% SNR is varied from 1 to 40, with 20 simulation?recovery iterations performed per SNR level.
% To change SNR variation, adapt line 17 
% To change iteration per SNR level, adapt line 18.


snr_vals = 1:40;
n_simulations = 20;  
mean_rmse1 = zeros(size(snr_vals));

for i = 1:length(snr_vals)
    SNR = snr_vals(i);
    fprintf('Running for SNR = %d\n', SNR);
    
    rmse = zeros(n_simulations, 1);
   
    
    for sim = 1:n_simulations
        [posterior,out] = beliefupdating_simrecover_SNRvar(SNR);        
        true_p = [0.7; 0.1];
        est_p = [posterior.muPhi(1); posterior.muPhi(2)];
        rmse(sim) = sqrt(mean((true_p-est_p).^2));        
    end
    
    mean_rmse1(i) = mean(rmse);      
end


figure;
plot(snr_vals, mean_rmse1, 'r-o');
xlabel('SNR');
ylabel('RMSE');
legend();
set(gca, 'FontSize', 20, 'LineWidth', 1.5);
grid on;
