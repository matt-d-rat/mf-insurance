/**
 * mf-insurance/action_removeInsurance.sqf
 * Removes an insurance policy from an insured vehicle.
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 0.1.0
 * MIT Licence
 **/

private ["_player", "_vehicleName", "_insuranceData", "_insuredID", "_dialog", "_animState", "_started", "_finished", "_isMedic"];

disableSerialization;

_player = player;

_vehicleName = MF_Insurance_Current_Item select 0 select 1;
_insuranceData = MF_Insurance_Current_Item select 1;
_insuredID = _insuranceData select 4;

_dialog = findDisplay MF_Insurance_iddDialog; // Get a reference to the display
_dialog closeDisplay 9000;

if(DZE_ActionInProgress) exitWith { 
	cutText["Insurance cover is already in the process of being removed." , "PLAIN DOWN"]; 
};

DZE_ActionInProgress = true;

// Begin animation
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

// Animation has finished, remove the insurance cover for the vehicle
if (_finished) then {
	private ["_key", "_result"];

	_key = format ["DELETE FROM `mf_insurance_policy_data` WHERE `InsuredID` = '%1';", _insuredID];
	_result = _key call server_hiveReadWrite;
	diag_log ("HIVE: DELETE: Delete insurance policy: " + str(_key) );
	_key = nil;
	_result = nil;

	cutText[format["Successfully removed insurance cover for %1. This vehicle is no longer insured.", _vehicleName], "PLAIN DOWN"];
};

DZE_ActionInProgress = false;