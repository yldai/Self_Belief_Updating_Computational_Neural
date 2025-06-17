# Self_Belief_Updating_Computational_Neural
The repository contains de-identified effective connectivity data and the codes used to support the main findings in the Dai et al. manuscript

## Model 1: general self belief updating and update magnitude modulatory effect

First combine all the GCM_controls_all_kx.mat into GCM_controls_all.mat using the [combine_GCM_upd.m](data/combine_GCM_upd.m).

The [Run_PEB_upd.m](analysis/Run_PEB_upd.m) reproduces the DCM exploring both the general self belief updating modulatory effect and the association between effective connectivity and the update magnitude. Click ‘Please select...’ on the resulting 'PEB - review parameters' screen and choose ‘Second-level effect - mean’ will demonstrate the general modulatory effect. Choose ‘Second-level effect - UPDsumcon’ will display the magnitude modulated parameters. Please select posterior probability (Pp) > 0.95 as the threshold. 

## Model 2: favorable and unfavorable updating modulatory effect

First combine all the GCM_controls_bg_kx.mat into GCM_controls_bg.mat using the [combine_GCM_bg.m](data/combine_GCM_bg.m).

The [Run_PEB_bg.m](analysis/Run_PEB_bg.m) reproduces the DCM exploring the distrinct modulatory effects of favorable and unfavorable updating. Please select posterior probability (Pp) > 0.95 as the threshold. 



