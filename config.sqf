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
		["UH1Y_DZ", [2, "ItemBriefcase100oz"], 2],
		["policecar", [1, "ItemBriefcase100oz"], 1],
		["Zodiac", [1, "ItemBriefcase100oz"], 1]
	];

	_config
};

/**
 * Returns an array of arrays, representing the frequencies of which a policy
 * bill will incur. Each array is represented as ["Display Name", "MySQL Enum"]
 * where the MySQL Enum is a unit expected by the MySQL TIMESTAMPDIFF function:
 *		FRAC_SECOND,
 *		SECOND,
 *		MINUTE,
 *		HOUR,
 *		DAY,
 *		WEEK,
 *		MONTH,
 *		QUARTER,
 *		YEAR
 *
 * It is not recommended that change the default configuration below. If you do it
 * is at your own risk, and it is advised you do not use a frequency less than DAY.
 * No support will be provided to anyone who changes the default configuration.
 **/
MF_Insurance_Frequency_Array = 
{
	private ["_frequencies"];

	_frequencies = [
		["Daily", "DAY"],
		["Weekly", "WEEK"],
		["Monthly", "MONTH"],
		["Quarterly", "QUARTER"],
		["Yearly", "YEAR"]
	];

	_frequencies
};