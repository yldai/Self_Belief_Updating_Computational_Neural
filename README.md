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


## Dynamic causal modelling Model 1: average effective connectivity modulation and magnitude-related variance during self-belief updating

First combine all the GCM_controls_all_kx.mat into GCM_controls_all.mat using the [combine_GCM_ME.m](data/combine_GCM_ME.m).

The [Run_PEB_ME.m](analysis/Run_PEB_ME.m) reproduces the parametric empirical Bayes (PEB) results for Model 1, which examined overall self-belief updating modulatory effects and update magnitude (proportion to estimation error corrected) associated variance in effective connectivity during self-belief updating. Select B-matrix on the 'PEB - review parameters' screen, set input as 'up'. Click ‘Please select...’ dropdown, choose ‘Second-level effect - Mean’ for the general modulatory effects. Choose ‘Second-level effect - ME’ for update magnitude associated variance. Please select posterior probability (Pp) > 0.95 as the threshold. 

## Dynamic causal modelling Model 2: valence-dependent modulatory effects

First combine all the GCM_controls_bg_kx.mat into GCM_controls_bg.mat using the [combine_GCM_bg.m](data/combine_GCM_bg.m).

The [Run_PEB_bg.m](analysis/Run_PEB_bg.m) reproduces PEB results for Model 2, which examined distrinct modulatory effects of favorable and unfavorable trials. Select B-matrix on the 'PEB - review parameters' screen, set input as 'g' for favorable trials, and 'b' for unfavorable trials. Click ‘Please select...’ dropdown, choose ‘Second-level effect - Mean’ for the modulatory effects. Please select posterior probability (Pp) > 0.95 as the threshold. 
