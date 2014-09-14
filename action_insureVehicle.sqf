/**
 * mf-insurance/action_insureVehicle.sqf
 * Insures an owned vehicle which has not yet been insured. 
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 0.1.0
 * MIT Licence
 **/

private ["_player", "_playerUID", "_vehicleObj", "_vehicleName", "_objectUID", "_characterID", "_dialog", "_insurancePolicy", "_insuranceVehicleClassname", "_insuranceAmount", "_insuranceCurrencyQty", "_insuranceCurrencyClassname", "_insuranceFrequency"];

disableSerialization;

_player = player;

//_playerUID = getPlayerUID _player; // Use this for real releases.
_playerUID = _player getVariable ["playerUID", 0]; // TEMP for DayZ Epoch Live Edior

_vehicleObj = MF_Insurance_Current_Item select 0 select 0;
_vehicleName = MF_Insurance_Current_Item select 0 select 1;
_objectUID = _vehicleObj getVariable["ObjectUID", 0];
_characterID = _vehicleObj getVariable["CharacterID", 0];

_insurancePolicy = _vehicleObj call MF_Insurance_Vehcile_Get_Insurance_Policy;
_insuranceVehicleClassname = _insurancePolicy select 0;
_insuranceAmount = _insurancePolicy select 1;
_insuranceCurrencyQty = _insuranceAmount select 0;
_insuranceCurrencyClassname = _insuranceAmount select 1;
_insuranceFrequency = _insurancePolicy select 2;

_dialog = findDisplay MF_Insurance_iddDialog; // Get a reference to the display

_dialog closeDisplay 9000;

// Check if the player has enough money in their inventory to insure the vehicle
if( ({_x == _insuranceCurrencyClassname} count (magazines _player)) >= _insuranceCurrencyQty) then {
	private ["r_interrupt", "_animState", "r_doLoop", "_started", "_finished", "_isMedic"];

	if(DZE_ActionInProgress) exitWith { 
		cutText ["Purchasing insurance for a vehicle already in progress." , "PLAIN DOWN"]; 
	};

	DZE_ActionInProgress = true;

	[1,1] call dayz_HungerThirst;
	_player playActionNow "Medic";

	r_interrupt = false;
	_animState = animationState _player;
	r_doLoop = true;
	_started = false;
	_finished = false;

	while {r_doLoop} do {
		_animState = animationState _player;
		_isMedic = ["medic",_animState] call fnc_inString;

		if (_isMedic) then {
			_started = true;
		};
		
		if (_started and !_isMedic) then {
			r_doLoop = false;
			_finished = true;
		};

		if (r_interrupt) then {
			r_doLoop = false;
		};

		sleep 0.1;
	};

	r_doLoop = false;

	if (!_finished) exitWith {
		r_interrupt = false;

		if (vehicle _player == _player) then {
			[objNull, _player, rSwitchMove,""] call RE;
			_player playActionNow "stop";
		};
		
		cutText [(localize "str_epoch_player_106") , "PLAIN DOWN"];
		
		DZE_ActionInProgress = false;
	};

	if (_finished) then {
		private ["_key", "_result", "_policyID", "_insuredID"];
		_key = nil;

		// Take the payment from the player
		[_player, _insuranceCurrencyClassname, _insuranceCurrencyQty] call BIS_fnc_invRemove;
		
		//TODO: calculate change to give
		//[[[_insuranceCurrencyClassname,_insuranceCurrencyQty]],1] call epoch_returnChange;
		
		// Crate a new policy in the database if the player hasn't previously created an insurance policy before
		_key = format ["INSERT IGNORE INTO `mf_insurance_policy`(`PlayerUID`) VALUES ('%1');", _playerUID];
		_result = _key call server_hiveReadWrite;
		diag_log ("HIVE: WRITE: Create player policy: " + str(_key) );
		_key = nil;
		_result = nil;

		// Get the player's policy ID from the database
		_key = format ["SELECT `PolicyID` FROM `mf_insurance_policy` WHERE `PlayerUID` = '%1';", _playerUID];
		_result = _key call server_hiveReadWrite;
		diag_log ("HIVE: READ: Get player policy ID: " + str(_key) );
		diag_log ("HIVE: RESULT: Get player policy ID: " + str(_result) );

		_policyID = parseNumber(_result select 0 select 0 select 0);
		_key = nil;
		_result = nil;

		// Create a new insurance record for the vehicle being insured
		_key = format ["INSERT IGNORE INTO `mf_insurance_policy_data` (`PolicyID`, `ObjectUID`, `Classname`, `CharacterID`, `InsuranceAmount`, `Frequency`) VALUES ('%1', '%2', '%3', '%4', '%5', '%6'); SELECT `InsuredID` FROM `mf_insurance_policy_data` WHERE `PolicyID` = '%1' AND `ObjectUID` = '%2';", _policyID, _objectUID, _insuranceVehicleClassname, _characterID, _insuranceAmount, _insuranceFrequency];
		_result = _key call server_hiveReadWrite;
		diag_log ("HIVE: WRITE: Create vehicle insurance record: " + str(_key) );
		diag_log ("HIVE: RESULT: Create vehicle insurance InsuredID: " + str(_result) );

		_insuredID = parseNumber(_result select 0 select 0 select 0);
		_key = nil;
		_result = nil;

		// Add a payment record to the payments table
		_key = format ["INSERT INTO `mf_insurance_payments` (`InsuredID`, `PaymentClassname`, `PaymentQty`) VALUES ('%1', '%2', '%3');", _insuredID, _insuranceCurrencyClassname, _insuranceCurrencyQty];
		_result = _key call server_hiveReadWrite;
		diag_log ("HIVE: WRITE: Create payment record: " + str(_key) );
		_key = nil;
		_result = nil;
		
		cutText [format["Successfully insured %1 for %2 %3.", _vehicleName, _insuranceCurrencyQty, _insuranceCurrencyClassname], "PLAIN DOWN"]; 
	};
} 
else {
	cutText[format["%1 %2 is required to insure %3.", _insuranceCurrencyQty, _insuranceCurrencyClassname, _vehicleName], "PLAIN DOWN"];
};

DZE_ActionInProgress = false;

//TODO:
//  - Prevent two players insuring the same vehicle at the same time. First in wins.


// This is how to return the number of days passed since the last payment timestamp in SQL:
// SELECT DATEDIFF(CURRENT_TIMESTAMP,`Datestamp`) AS TotalDaysPassed FROM `mf_insurance_payments` ORDER BY `PaymentID` DESC LIMIT 1;