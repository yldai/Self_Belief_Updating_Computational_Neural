# Self_Belief_Updating_Computational_Neural
The repository contains de-identified behavioral and effective connectivity data and the codes used to support the main findings in the Dai et al. manuscript.

## Descriptive statistics
The [dai_beh_stats.m](analysis/dai_beh_stats.m) reproduces inferential statistics including the proportion of updated trials regardless of valence and by valence (favorable v. unfavorable), and the mean update magnitudes by valence (favorable v. unfavorable, proportion of estimation error corrected). Please run [dai_beh_stats.m](analysis/dai_beh_stats.m) before running upd_data_bmc.m from https://github.com/mdgreaves/belief-updating-model, and other adapted behavioral models ([upd_data_bmc.m](analysis/behavioral_model_participant_valence/upd_data_bmc.m) for behavioral modelling based on participant defined word valence, and [upd_data_bmc.m](analysis/behavioral_model_scaling_a/upd_data_bmc.m) for behavioral modelling with baseline learning scaled by estimation error magnitude). 

The [beh_stats2.m](analysis/beh_stats2.m) reproduces descriptive statistics including the average total number of trials, the average number of updated trials, the average total and trial-wise estimation error magnitudes by valence (favorable v. unfavorable). 

The [beh_stats3.m](analysis/beh_stats3.m) reproduces the average valence rating scores by valence (favorable v. unfavorable).

The [mixed_model_by_word.m](analysis/mixed_model_by_word.m) reproduces mixed effects models fitted to trial-wise estimation error magnitudes, updated trial
% proportions, and update magnitudes by word across participants, with favorability being the fixed effect.

The [mixed_effects_update_choice.m](analysis/mixed_effects_update_choice.m) reproduces the mixed effects model fitted to update choice.

## Static belief updating model
Please refer to https://github.com/mdgreaves/belief-updating-model 
This repository contains MATLAB code for simulating, inverting, and validating a static self-belief updating model. The model captures how participants adjust their self-belief ratings in response to feedback, allowing for asymmetric learning when information is favorable versus unfavorable.

The behavioral model where favorability of trials are defined based on participant-provided word valence ratings could be performed using ([upd_data_bmc.m](analysis/behavioral_model_participant_valence/upd_data_bmc.m). The behavioral model where baseline learning is scaled by estimation error magnitude could be performed using [upd_data_bmc.m](analysis/behavioral_model_scaling_a/upd_data_bmc.m).

## Base rate generative procedure

The [BR_sim_full.m](analysis/BR_sim_full.m) iteratively simulates base rate datasets based on the generative, vectorized Gaussian model specified in Supplementary Results. Specifically, through this algorithm, adjusted base rates were sampled independently for each attribute from a Gaussian distribution with mean (μ[k]) and standard deviation (3/4σ[k]). Each draw was rounded to the nearest five percentage points and bounded between 5% and 95%. For each sampled set, we first calculated the absolute estimation error for every trial and classified the error as favorable or unfavorable according to the interaction between attribute valence and error direction. 

If the total favorable error magnitude (EEf) was larger than unfavorable error magnitude (EEu) by 10 percentage points or more, all favorable trials were pooled by descending trial-wise error magnitude (EE[k]), and target condition was set to unfavorable. The opposite applied if the total unfavorable error magnitude was larger than favorable error magnitude by 10 percentage points or more. For all trials in the pool, the algorithm iteratively attempted to redraw each base rate from the Gaussian distribution until the trial met the target condition. If this attempt failed, the algorithm then redrew each base rate until the trial-wise error magnitude (EE[k]) was reduced compared to before the redraw. 

Sampling broke when the difference between favorable and unfavorable error magnitudes was less than 10 percentage points. The main goal for sampling adjusted base rates was to reach approximately equal estimation error magnitudes across valence. The behavioral data and algorithm codes are available in the github repository accompanying this submission. The full algorithm was performed for 1000 times to generate multiple base rate datasets. 

Figure S1a could be reproduced using [BR_parity_plot.m](analysis/BR_parity_plot.m), Figure S1b could be reproduced using [BR_R2_distribution2.m](analysis/BR_R2_distribution2.m).

## Dynamic causal modelling Model 1: average effective connectivity modulation and magnitude-related variance during self-belief updating

First combine all the GCM_controls_all_kx.mat into GCM_controls_all.mat using the [combine_GCM_ME.m](data/combine_GCM_ME.m).

The [Run_PEB_ME.m](analysis/Run_PEB_ME.m) reproduces the parametric empirical Bayes (PEB) results for Model 1, which examined overall self-belief updating modulatory effects and update magnitude (proportion to estimation error corrected) associated variance in effective connectivity during self-belief updating. Select B-matrix on the 'PEB - review parameters' screen, set input as 'up'. Click ‘Please select...’ dropdown, choose ‘Second-level effect - Mean’ for the general modulatory effects. Choose ‘Second-level effect - ME’ for update magnitude associated variance. Please select posterior probability (Pp) > 0.95 as the threshold. 

## Dynamic causal modelling Model 2: valence-dependent modulatory effects

First combine all the GCM_controls_bg_kx.mat into GCM_controls_bg.mat using the [combine_GCM_bg.m](data/combine_GCM_bg.m).

The [Run_PEB_bg.m](analysis/Run_PEB_bg.m) reproduces PEB results for Model 2, which examined distrinct modulatory effects of favorable and unfavorable trials. Select B-matrix on the 'PEB - review parameters' screen, set input as 'g' for favorable trials, and 'b' for unfavorable trials. Click ‘Please select...’ dropdown, choose ‘Second-level effect - Mean’ for the modulatory effects. Please select posterior probability (Pp) > 0.95 as the threshold. 

## PEB Model 1 & 2 sensitivity analysis

The [Run_PEB_ME_new.m](analysis/Run_PEB_ME_new.m) reproduces the sensitivity analysis results for PEB Model 1. Three additional regressors - favorable versus unfavorable trial number ratio, trial-wise error magnitude ratio and age - were included to examine potential confounding effects.  Click ‘Please select...’ dropdown, choose ‘Second-level effect - Mean’ for the general modulatory effects. Choose ‘Second-level effect - ME’ for update magnitude associated variance. Choose ‘Second-level effect - tEE_mc’ for trial-wise error magnitude ratio associated variance. Choose ‘Second-level effect - nfavunfav_mc’ for trial number ratio associated variance. Choose ‘Second-level effect - age’ for age associated variance. Please select posterior probability (Pp) > 0.95 as the threshold.

The [Run_PEB_bg_new.m](analysis/Run_PEB_bg_new.m) reproduces the sensitivity analysis results for PEB Model 2. Three additional regressors - favorable versus unfavorable trial number ratio, trial-wise error magnitude ratio and age - were included to examine potential confounding effects. Click ‘Please select...’ dropdown, choose ‘Second-level effect - Mean’ for the modulatory effects. Choose ‘Second-level effect - tEE_mc’ for trial-wise error magnitude ratio associated variance. Choose ‘Second-level effect - nfavunfav_mc’ for trial number ratio associated variance. Choose ‘Second-level effect - age’ for age associated variance. Please select posterior probability (Pp) > 0.95 as the threshold.
