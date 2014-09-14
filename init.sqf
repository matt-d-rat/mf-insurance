/**
 * mf-insurance/init.sqf
 * The main script for initalising the insurance addon. 
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 0.1.0
 * MIT Licence
 **/

private ["_cursorTarget"];

// Public Local Constants
MF_Insurance_Base_Path =  "addons\mf-insurance"; 		// The base path to the MF-Insurance script folder, relative to where the script is initialised.
MF_Insurance_Min_Distance_From_Vehicle = 10;

// Fetch the config file
#include "config.sqf";

_cursorTarget = cursorTarget;

// TODO: Check we are looking at a trader

s_player_mf_insurance = player addAction ["Vehicle Insurance", format["%1\player_mfInsuranceDialog.sqf", MF_Insurance_Base_Path], _cursorTarget, 0, false, true, "",""];	