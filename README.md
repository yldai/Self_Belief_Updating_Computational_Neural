# Self_Belief_Updating_Computational_Neural
The repository contains de-identified behavioral and effective connectivity data and the codes used to support the main findings in the Dai et al. manuscript

## Computational modeling: model building and testing via simulation-recovery analysis 

The [basic_model.m](computational_model/basic_model.m) reproduces what's presented in Supplementary Figure 2. This script defines and tests the self belief updating generative model, with visualization of simulated updating behaviors generated to verify model performance.

The [beliefupdating_simrecover.m](computational_model/beliefupdating_simrecover.m) reproduces the simulation-recovery analysis specified in Supplementary Methods and Figure 3-4. This function could be run standalone or called using [beliefupdating_abplot.m](computational_model/beliefupdating_simrecover.m). When it's run independently, simulation-recovery analysis will be performed for one time, yielding simulated and recovered parameter values and posterior distributions as well as log evidence to examine the reliability of parameter recovery. For this simulation-recovery analysis, signal to noise ratio (SNR) is fixed at 40. See comments in the beginning of script for specific instructions.

The [beliefupdating_abplot.m](computational_model/beliefupdating_simrecover.m) calls 'beliefupdating_simrecover.m' and iteratively perform simulation-recovery analysis with 
 parameters a and b randomly sampled from Gaussian distribution. This function reproduces what's presented in Supplementary Figure 6. Simulated and recovered (inferred) parameter values from each iteration will be aggregated and compared, with pearson's correlation coefficient (R) and root mean squared error (RMSE) computed to quantify accuracy of parameter recovery. See comments in the beginning of script for specific instructions.
 
The [beliefupdating_simrecover_SNRvar.m](computational_model/beliefupdating_simrecover_SNRvar.m) is a non-independent function used to test model performance across a range of signal-to-noise ratios (SNRs). This function is called using [SNR_loop.m](computational_model/SNR_loop.m), which inputs variations of SNR and iteratively perform simulation-recovery analysis per SNR level. For each SNR, simulated and recovered (inferred) parameter values are collected to compute RMSE as presented in Supplementary Figure 7. quantify the accuracy of parameter recovery as a function of SNR. See comments in the beginning of script for specific instructions.

The [beliefupdating_sample.m](computational_model/beliefupdating_sample.m) reproduces Supplementary Figure 5. This script is adapted from [beliefupdating_simrecover.m](computational_model/beliefupdating_simrecover.m), with BR and E1 semi-randomly sampled, and V pseudo-randomly sampled. See comments in the beginning of script for specific instructions to reproduce variations of simulated updating behaviors.

## Computational modeling: model inversion using real experimental data

The [100_linearmodel_all.csv](computational_model/100_linearmodel_all.csv) is a surrogate participant file that's loaded to perform the model inversion function. 

Model inversion at subject level is performed using [beliefupdating_invert_real.m](computational_model/beliefupdating_invert_real.m). Through inverting the model at subject level, posterior distributions of parameters, posterior probabilities and Bayesian log model evidence are estimated and visualized via built in functions of VBA. This function reproduces what's presented in Supplementary Figure 4. 

## Computational modeling: Bayesian model averaging (BMA) and random effect Bayesian model comparison

The [beliefupdating_BMA.m](computational_model/beliefupdating_BMA.m) is used to derive the group-level parameter estimates and posterior probabilities. This function is adapted from [beliefupdating_invert_real.m](computational_model/beliefupdating_invert_real.m), adding a for loop to iteratively invert the model to all participants. Posterior outputs were collated for the BMA procedures. 

Collated de-identified posterior outputs and free energy approximations (i.e. low bound Bayesian log model evidence) from subject level model inversion could be found in [posterior_all.mat](computational_model/posterior_all.mat) and [F_all.mat](computational_model/F_all.mat). The files could be loaded to perform the BMA using line 47-61 of  [beliefupdating_BMA.m](computational_model/beliefupdating_BMA.m) to reproduce findings specified in Supplementary Methods. 

The [beliefupdating_modelcomparison.m](computational_model/beliefupdating_modelcomparison.m) is used to derive free energy approximations across all compared models (i.e. full and reduced models). This function iteratively invert the full model and the reduced models to each participant through selectively fixing prior mean and covariance to zero and performing VBA_NLStateSpaceModel function using different parameter permutations. Free energy approximations across models were combined and saved in [F_values_matrix.mat](computational_model/F_values_matrix.mat) for random effect Bayesian Model Comparison.

The [beliefupdating_BMC.m](computational_model/beliefupdating_BMC.m) reproduces main findings presented in Figure 3. The free energy approximation values collated in [F_values_matrix.mat](computational_model/F_values_matrix.mat) are inputed to call the VBA_groupBMC function, which estimates model attribution for each participant, expected model frequencies and protected exceedance probabilities across all compared models. 

## Dynamic causal modeling Model 1: general self belief updating and update magnitude modulatory effect

First combine all the GCM_controls_all_kx.mat into GCM_controls_all.mat using the [combine_GCM_upd.m](data/combine_GCM_upd.m).

The [Run_PEB_upd.m](analysis/Run_PEB_upd.m) reproduces the DCM exploring both the general self belief updating modulatory effect and the association between effective connectivity and the update magnitude. Click ‘Please select...’ on the resulting 'PEB - review parameters' screen and choose ‘Second-level effect - mean’ will demonstrate the general modulatory effect. Choose ‘Second-level effect - UPDsumcon’ will display the magnitude modulated parameters. Please select posterior probability (Pp) > 0.95 as the threshold. 

## Dynamic causal modeling Model 2: favorable and unfavorable updating modulatory effect

First combine all the GCM_controls_bg_kx.mat into GCM_controls_bg.mat using the [combine_GCM_bg.m](data/combine_GCM_bg.m).

The [Run_PEB_bg.m](analysis/Run_PEB_bg.m) reproduces the DCM exploring the distrinct modulatory effects of favorable and unfavorable updating. Please select posterior probability (Pp) > 0.95 as the threshold. 
