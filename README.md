# Self_Belief_Updating_Computational_Neural
The repository contains de-identified behavioral and effective connectivity data and the codes used to support the main findings in the Dai et al. manuscript.

## Dynamic causal modelling Model 1: average effective connectivity modulation and magnitude-related variance during self-belief updating

First combine all the GCM_controls_all_kx.mat into GCM_controls_all.mat using the [combine_GCM_ME.m](data/combine_GCM_ME.m).

The [Run_PEB_ME.m](analysis/Run_PEB_ME.m) reproduces the parametric empirical Bayes (PEB) results for Model 1, which examined overall self-belief updating modulatory effects and update magnitude (proportion to estimation error corrected) associated variance in effective connectivity during self-belief updating. Select B-matrix on the 'PEB - review parameters' screen, set input as 'up'. Click ‘Please select...’ dropdown, choose ‘Second-level effect - Mean’ for the general modulatory effects. Choose ‘Second-level effect - ME’ for update magnitude associated variance. Please select posterior probability (Pp) > 0.95 as the threshold. 

## Dynamic causal modeling Model 2: valence-dependent modulatory effects

First combine all the GCM_controls_bg_kx.mat into GCM_controls_bg.mat using the [combine_GCM_bg.m](data/combine_GCM_bg.m).

The [Run_PEB_bg.m](analysis/Run_PEB_bg.m) reproduces PEB results for Model 2, which examined distrinct modulatory effects of favorable and unfavorable trials. Select B-matrix on the 'PEB - review parameters' screen, set input as 'g' for favorable trials, and 'b' for unfavorable trials. Click ‘Please select...’ dropdown, choose ‘Second-level effect - Mean’ for the modulatory effects. Please select posterior probability (Pp) > 0.95 as the threshold. 
