# Self_Belief_Updating_Computational_Neural
The repository contains de-identified behavioral and effective connectivity data and the codes used to support the main findings in the Dai et al. manuscript

## Computational modeling: model building and testing via simulation-recovery analysis 

The [basic_model.m](computational_model/basic_model.m) reproduces what's presented in Supplementary Figure 2. This script defines and tests the self belief updating generative model, with visualization of simulated updating behaviors generated to verify model performance.

The [beliefupdating_simrecover.m](computational_model/beliefupdating_simrecover.m) reproduces the simulation-recovery analysis specified in Supplementary Methods and Figure 3-4. This function could be run standalone or called using [beliefupdating_abplot.m](computational_model/beliefupdating_simrecover.m). When it's run independently, simulation-recovery analysis will be performed for one time, yielding simulated and recovered parameter values and posterior distributions as well as log evidence to examine the reliability of parameter recovery. For this simulation-recovery analysis, signal to noise ratio (SNR) is fixed at 40. See comments in the beginning of script for specific instructions.

The [beliefupdating_abplot.m](computational_model/beliefupdating_simrecover.m) calls 'beliefupdating_simrecover.m' and iteratively perform simulation-recovery analysis with 
 parameters a and b randomly sampled from Gaussian distribution. This function reproduces what's presented in Supplementary Figure 6. Simulated and recovered (inferred) parameter values from each iteration will be aggregated and compared, with pearson's correlation coefficient (R) and root mean squared error (RMSE) computed to quantify accuracy of parameter recovery. See comments in the beginning of script for specific instructions.
 
 The [beliefupdating_simrecover_SNRvar.m](computational_model/beliefupdating_simrecover_SNRvar.m) is a non-independent function used to test model performance across a range of signal-to-noise ratios (SNRs). This function is called using [SNR_loop.m](computational_model/SNR_loop.m), which inputs variations of SNR and iteratively perform simulation-recovery analysis per SNR level. For each SNR, simulated and recovered (inferred) parameter values are collected to compute RMSE as presented in Supplementary Figure 7. quantify the accuracy of parameter recovery as a function of SNR. See comments in the beginning of script for specific instructions.

## Computational modeling: model inversion using real experimental data

The [100_linearmodel_all.csv](computational_model/100_linearmodel_all.csv) is a surrogate participant file that's loaded in to perform the model inversion function. 

## Computational modeling: Bayesian model averaging and random effect Bayesian model comparison


## Dynamic causal modeling Model 1: general self belief updating and update magnitude modulatory effect

First combine all the GCM_controls_all_kx.mat into GCM_controls_all.mat using the [combine_GCM_upd.m](data/combine_GCM_upd.m).

The [Run_PEB_upd.m](analysis/Run_PEB_upd.m) reproduces the DCM exploring both the general self belief updating modulatory effect and the association between effective connectivity and the update magnitude. Click ‘Please select...’ on the resulting 'PEB - review parameters' screen and choose ‘Second-level effect - mean’ will demonstrate the general modulatory effect. Choose ‘Second-level effect - UPDsumcon’ will display the magnitude modulated parameters. Please select posterior probability (Pp) > 0.95 as the threshold. 

## Dynamic causal modeling Model 2: favorable and unfavorable updating modulatory effect

First combine all the GCM_controls_bg_kx.mat into GCM_controls_bg.mat using the [combine_GCM_bg.m](data/combine_GCM_bg.m).

The [Run_PEB_bg.m](analysis/Run_PEB_bg.m) reproduces the DCM exploring the distrinct modulatory effects of favorable and unfavorable updating. Please select posterior probability (Pp) > 0.95 as the threshold. 

