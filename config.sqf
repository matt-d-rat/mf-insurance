/**
 * mf-insurance/config.sqf
 * Configuration file for setting the insurance policy for each vehicle.
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 0.1.0
 * MIT Licence
 **/


/**
 * Returns an array of vehicle insurance policies. Each policy is defined as an array 
 * in the _config array. Defined in the format of: 
 * ["Vehicle_Class_Name", [quantity, "Currency_Class_Name"], frequencyId]
 *
 * Example:
 * ["UH1Y_DZE", [2, "ItemBriefcase10oz"], 2]
 *
 * "Vehcile_Class_Name" = The class name of the vehicle for the insurance policy.
 * quantity = The quantity of currecy items needed for payment.
 * "Currency_Class_Name" = The class name of the currency item.
 * frquencyId = the id of payment frequency:
 *		0 = Daily
 *		1 = Weekly
 *		2 = Monthly
 *		3 = Yearly
 **/
MF_Insurance_Policy_Config_Array = 
{
	private ["_config"];

	_config = [
		["UH1Y_DZ", [2, "ItemBriefcase100oz"], 2]
	];

	_config
};