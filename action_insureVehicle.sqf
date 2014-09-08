/**
 * mf-insurance/action_insureVehicle.sqf
 * Insures an owned vehicle which has not yet been insured. 
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 0.1.0
 * MIT Licence
 **/

private ["_player", "_playerUID", "_vehicleObj", "_vehicleName", "_dialog", "_insurancePolicy", "_insuranceCost", "_insuranceQty", "_insuranceItemClass"];

disableSerialization;

_player = player;

//_playerUID = getPlayerUID _player; // Use this for real releases.
_playerUID = _player getVariable ["playerUID", "0"]; // TEMP for DayZ Epoch Live Edior

_vehicleObj = MF_Insurance_Current_Item select 0 select 0;
_vehicleName = MF_Insurance_Current_Item select 0 select 1;
_insurancePolicy = _vehicleObj call MF_Insurance_Vehcile_Get_Insurance_Policy;

_insuranceCost = _insurancePolicy select 1;
_insuranceQty = _insuranceCost select 0;
_insuranceItemClass = _insuranceCost select 1;

_dialog = findDisplay MF_Insurance_iddDialog; // Get a reference to the display

_dialog closeDisplay 9000;

// Check if the player has enough money in their inventory to insure the vehicle
if( ({_x == _insuranceItemClass} count (magazines _player)) >= _insuranceQty) then {
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
		private ["_result", "_key", "_existingPolicy"];

		_result = nil;
		_key = nil;

		// Take the payment from the player
		//_result = [_player, _insuranceItemClass, _insuranceQty] call BIS_fnc_invRemove;
		
		//TODO: calculate change to give
		//[[[_insuranceItemClass,_insuranceQty]],1] call epoch_returnChange;
		
		// Check if the player already has a policy in the database
		_key = format ["CHILD:999:SELECT `PolicyID` FROM `mf_insurance_policy` WHERE `PlayerUID`` = ?:[%1]:", parseNumber(_playerUID)];
		diag_log ("HIVE: READ: Get Existing Policy for player: " + str(_key) );
		_existingPolicy = _key call server_hiveReadWrite;
		diag_log ("HIVE: READ: Get Existing Policy for player result: " + str(_existingPolicy) );
		_key = nil;

		cutText[ format["result = %1", _existingPolicy], "PLAIN DOWN"];

		//cutText [format["Successfully insured %1 for %2 %3.", _vehicleName, _insuranceQty, _insuranceItemClass], "PLAIN DOWN"]; 
	};
} 
else {
	cutText[format["%1 %2 is required to insure %3.", _insuranceQty, _insuranceItemClass, _vehicleName], "PLAIN DOWN"];
};

DZE_ActionInProgress = false;

//TODO:
//	- Write the result to the DB.
// 	- Verify the result wrote correctly to the DB
//  - Prevent two players insuring the same vehicle at the same time. First in wins.


// Example SQL
// _key = format ["CHILD:999: select id from building WHERE class_name= '%1' AND id > ?:[0]:", _classname];
// diag_log ("HIVE: WRITE: ChangedOwner "+ str(_key));
// _result = _key call server_hiveReadWrite;
// diag_log ("HIVE: WRITE: ChangedOwner result "+ str(_result));