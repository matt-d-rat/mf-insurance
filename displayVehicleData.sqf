/**
 * mf-insurance/displayVehicleData.sqf
 * Displays the vehicle data in the right hand side of the panel. 
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 0.1.0
 * MIT Licence
 **/

private [
	"_dialog", "_item", "_vehicleObj", "_vehicleName", "_vehicleImage", "_insuranceData", "_insurancePolicy", "_getLabelStatusText", "_getLabelCostText",
	"_getLabelFrequencyText", "_getLabelBalanceText", "_uninsuredDisplay", "_insuredVehicleDisplay", "_labelPrefixStatus", "_labelPrefixCost", 
	"_labelPrefixFrequency", "_labelPrefixBalance", "_labelPrefixPaymentDate", "_toolTipOutstandingBalance"
];

disableSerialization;

_dialog = findDisplay MF_Insurance_iddDialog; // Get a reference to the display

_labelPrefixStatus = "Status";
_labelPrefixCost = "Insurance cost";
_labelPrefixFrequency = "Frequency";
_labelPrefixBalance = "Balance";
_labelPrefixPaymentDate = "Payment due";

_toolTipOutstandingBalance = "You cannot %1 because you currently owe %2 on the insurance policy. Please pay the outstanding amount to enable this action.";

MF_Insurance_Current_Item = _this; // Has to be public due to event handler scopes being seperate from the parent thread.

_vehicleObj = MF_Insurance_Current_Item select 0 select 0;
_vehicleName = MF_Insurance_Current_Item select 0 select 1;
_vehicleImage = MF_Insurance_Current_Item select 0 select 2;
_insuranceData = MF_Insurance_Current_Item select 1;

_insurancePolicy = _vehicleObj call MF_Insurance_Vehcile_Get_Insurance_Policy;

_getInsuranceCostFromConfig =
{
	private ["_insuranceCost"];

	if( count _insurancePolicy > 0 ) then {
		_insuranceCost = _insurancePolicy select 1;
	} else {
		_insuranceCost = ["N/A", ""];
	};

	_insuranceCost
};

_getLabelStatusText =
{
	private ["_isInsured", "_labelSuffix", "_color", "_labelText"];
	_isInsured = _this select 0;

	switch (true) do {
		case ( _isInsured ): {
			_color = "#00ff00";
			_labelText = "Insured";
		};
		case ( (!_isInsured && (count _insurancePolicy > 0)) ): {
			_color = "#ff0000";
			_labelText = "Uninsured";
		};
		default {
			_color = "#f6bd0c";
			_labelText = "Insurance unavailable";
		};
	};

	_labelSuffix = format["<t color='%2'>%1</t>", _labelText, _color];
	format["%1: %2", _labelPrefixStatus, _labelSuffix]
};

_getLabelCostText =
{
	private ["_labelSuffix", "_insuranceCost", "_displayName"];

	if( ( count _insuranceData ) == 0 ) then {
		_insuranceCost = [] call _getInsuranceCostFromConfig;
	} else {
		_insuranceCost = [100, "ItemBriefcase10oz"]; // Get from insuranceData
	};

	// TODO, get the suffix 10oz gold bar
	_displayName = getText(configFile >> "CfgMagazines" >> (_insuranceCost select 1) >> "displayName");
	_labelSuffix = format["%1 %2", (_insuranceCost select 0), _displayName];

	format["%1: %2", _labelPrefixCost, _labelSuffix]
};

_getLabelFrequencyText =
{
	private ["_frequencies", "_labelSuffix"];
	_frequencies = ["Daily", "Weekly", "Monthly", "Yearly"];

	if( (count _insuranceData == 0) && (count _insurancePolicy > 0) ) then {
		_labelSuffix = _frequencies select (_insurancePolicy select 2);
	} else {
		_labelSuffix = "TODO"; // TODO pull from insurnaceData
	};

	format["%1: %2", _labelPrefixFrequency, _labelSuffix]
};

_getLabelBalanceText =
{
	private ["_labelSuffix", "_balance", "_displayName", "_color", "_currency"];

	_balance = [100, "ItemBriefcase10oz"]; //TODO: Logic from insuranceData
	
	// TODO: get the suffix 10oz gold bar
	_displayName = getText(configFile >> "CfgMagazines" >> (_balance select 1) >> "displayName");
	
	switch true do {
		// Positive balance
		case( (_balance select 0) > 0 ): { 
			_color = "#00ff00";
			_currency = _displayName;
		};

		// Negative balance
		case( (_balance select 0) < 0 ): { 
			_color = "#ff0000"; 
			_currency = _displayName;
		};

		// Zero balance
		default { 
			_color = "#ffffff";
			_currency = "";
		}; 							
	};

	_labelSuffix = format["<t color='%3'>%1 %2</t>", (_balance select 0), _currency, _color];

	format["%1: %2", _labelPrefixBalance, _labelSuffix]
};

_uninsuredVehicleDisplay =
{
	ctrlEnable [MF_Insurance_idcBtnRemove, false];
	ctrlEnable [MF_Insurance_idcBtnRecover, false];
	ctrlEnable [MF_Insurance_idcBtnPay, false];
	ctrlEnable [MF_Insurance_idcBtnInsure, true];

	(_dialog displayCtrl MF_Insurance_idcVehicleInfo_Status) ctrlSetStructuredText parseText ([false] call _getLabelStatusText);
	ctrlSetText [MF_Insurance_idcVehicleInfo_Cost, [] call _getLabelCostText];
	ctrlSetText [MF_Insurance_idcVehicleInfo_PaymentFrequency, [] call _getLabelFrequencyText];

	ctrlShow [MF_Insurance_idcVehicleInfo_Status, true];
	ctrlShow [MF_Insurance_idcVehicleInfo_Cost, true];
	ctrlShow [MF_Insurance_idcVehicleInfo_PaymentFrequency, true];
	ctrlShow [MF_Insurance_idcBtnInsure, true];

	(_dialog displayCtrl MF_Insurance_idcBtnInsure) ctrlAddEventHandler ["ButtonClick", "[] execVM format['%1\action_insureVehicle.sqf', MF_Insurance_Base_Path];"];
};

_notInsurableVehicleDisplay =
{
	ctrlEnable [MF_Insurance_idcBtnRemove, false];
	ctrlEnable [MF_Insurance_idcBtnRecover, false];
	ctrlEnable [MF_Insurance_idcBtnPay, false];
	ctrlEnable [MF_Insurance_idcBtnInsure, false];

	(_dialog displayCtrl MF_Insurance_idcVehicleInfo_Status) ctrlSetStructuredText parseText ([false] call _getLabelStatusText);

	ctrlShow [MF_Insurance_idcVehicleInfo_Status, true];
	ctrlShow [MF_Insurance_idcBtnInsure, true];
};

_insuredVehicleDisplay =
{
	private ["_owesPayment"];

	//TODO: get from insurance data, temp to test.
	_owesPayment = true;
	_vehicleIsAlive = true;
	
	ctrlEnable [MF_Insurance_idcBtnInsure, false];
	ctrlEnable [MF_Insurance_idcBtnPay, true];

	ctrlEnable [MF_Insurance_idcBtnRemove, !_owesPayment];
	ctrlEnable [MF_Insurance_idcBtnRecover, (!_owesPayment && !_vehicleIsAlive)];

	(_dialog displayCtrl MF_Insurance_idcVehicleInfo_Status) ctrlSetStructuredText parseText ([true] call _getLabelStatusText);
	ctrlSetText [MF_Insurance_idcVehicleInfo_Cost, [] call _getLabelCostText];
	ctrlSetText [MF_Insurance_idcVehicleInfo_PaymentFrequency, [] call _getLabelFrequencyText];
	(_dialog displayCtrl MF_Insurance_idcVehicleInfo_Balance) ctrlSetStructuredText parseText ([] call _getLabelBalanceText);

	ctrlShow [MF_Insurance_idcVehicleInfo_Status, true];
	ctrlShow [MF_Insurance_idcVehicleInfo_Cost, true];
	ctrlShow [MF_Insurance_idcVehicleInfo_PaymentFrequency, true];
	ctrlShow [MF_Insurance_idcVehicleInfo_Balance, true];
	ctrlShow [MF_Insurance_idcBtnRemove, true];
	ctrlShow [MF_Insurance_idcBtnRecover, true];
	ctrlShow [MF_Insurance_idcBtnPay, true];
};

// Show the common controls 
ctrlShow [MF_Insurance_idcVehicleTitle, true];
ctrlShow [MF_Insurance_idcVehicleImage, true];
ctrlShow [MF_Insurance_idcVehicleInfo_Pane, true];

// Populate new data
ctrlSetText [MF_Insurance_idcVehicleTitle, format["%1", _vehicleName]];
ctrlSetText [MF_Insurance_idcVehicleImage,  format["%1", _vehicleImage]];

switch(true) do {
	// Insured Vehicle
	case (count _insuranceData > 0 ): {
		[] call _insuredVehicleDisplay;
	};
	// Uninsured Vehicle
	case( (count _insuranceData == 0) && (count _insurancePolicy > 0) ): {
		[] call _uninsuredVehicleDisplay;	
	};
	default {
		[] call _notInsurableVehicleDisplay;
	};
};