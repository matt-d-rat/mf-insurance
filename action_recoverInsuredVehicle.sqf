/**
 * mf-insurance/action_recoverInsuredVehicle.sqf
 * Spawns a vehicle which is insured and has been destroyed.
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 0.1.0
 * MIT Licence
 **/

private ["_player", "_playerUID", "_vehicleClassname", "_vehicleName", "_originalObjectUID", 
		 "_originalKeyID", "_direction", "_helipad", "_spawnInWater", "_spawnLocation", "_spawnMarker",
		 "_vehicleKey", "_isValidKey", "_hasKey", "_playerInventory", "_playerBackpack", "_dialog"];

disableSerialization;

_player = player;

//_playerUID = getPlayerUID _player; // Use this for real releases.
_playerUID = _player getVariable ["playerUID", 0]; // TEMP for DayZ Epoch Live Editor

_vehicleClassname = MF_Insurance_Current_Item select 0 select 0;
_vehicleName = MF_Insurance_Current_Item select 0 select 1;
_originalObjectUID = MF_Insurance_Current_Item select 1 select 0;
_originalKeyID = parseNumber(MF_Insurance_Current_Item select 1 select 1);

_playerInventory = (weapons _player);
_playerBackpack = ((getWeaponCargo unitbackpack _player) select 0);

_direction = round(random 360);
_helipad = nearestObjects [player, ["HeliHCivil","HeliHempty"], 100];

_dialog = findDisplay MF_Insurance_iddDialog; // Get a reference to the display
_dialog closeDisplay 9000;

if(_vehicleClassname isKindOf "Ship") then {
	_spawnInWater = 2;
} else {
	_spawnInWater = 0;	
};

// Find a location to spawn the vehicle
if(count _helipad > 0) then {
	_spawnLocation = (getPosATL (_helipad select 0));
} else {
	_spawnLocation = [(position _player), 0, 20, 1, _spawnInWater, 2000, 0] call BIS_fnc_findSafePos;
};

// Check if the spawn location is suitable for vehicle types that are ships
if( _vehicleClassname isKindOf "Ship" && !surfaceIsWater _spawnLocation) exitWith {
	cutText[format["Cannot recover %1 at this location as this type of vehicle requires water.", _vehicleName],"PLAIN DOWN"];
};

// Check Key is a valid ID
if( _originalKeyID == 0) exitWith {
	cutText[format["Cannot recover %1, its vehcile key is not a valid key.", _vehicleName],"PLAIN DOWN"];
};

// Create key for vehicle from original character key
switch (true) do {
	case ( (_originalKeyID > 0) && (_originalKeyID <= 2500) ): {
		_vehicleKey = format["ItemKeyGreen%1", _originalKeyID];
	};
	case ( (_originalKeyID > 2500) && (_originalKeyID <= 5000) ): {
		_vehicleKey = format["ItemKeyRed%1", (_originalKeyID - 2500)];
	};
	case ( (_originalKeyID > 5000) && (_originalKeyID <= 7500) ): {
		_vehicleKey = format["ItemKeyBlue%1", (_originalKeyID - 5000)];
	};
	case ( (_originalKeyID > 7500) && (_originalKeyID <= 10000) ): {
		_vehicleKey = format["ItemKeyYellow%1", (_originalKeyID - 7500)];
	};
	case ( (_originalKeyID > 10000) && (_originalKeyID <= 12500) ): {
		_vehicleKey = format["ItemKeyBlack%1", (_originalKeyID - 10000)];
	};
	default {
		_vehicleKey = "ItemKey";
	};
};

_isValidKey = isClass(configFile >> "CfgWeapons" >> _vehicleKey);

// Check the player doesn't already have the key on them
if(_vehicleKey in (_playerInventory + _playerBackpack) ) then {
	_hasKey = true;
} else {
	_hasKey = [_player, _vehicleKey] call BIS_fnc_invAdd; // Add the key to the players inventory
};

waitUntil {!isNil "_hasKey"};

// TODO: Animation and close dialog

if (_hasKey and _isValidKey) then {
	private ["_animState", "_started", "_finished", "_isMedic"];

	if(DZE_ActionInProgress) exitWith { 
		cutText["Purchasing insurance for a vehicle already in progress." , "PLAIN DOWN"]; 
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
		private ["_newObjectUID"];

		// Place a vehicle spawn marker (local)
		_spawnMarker = createVehicle ["Sign_arrow_down_large_EP1", _spawnLocation, [], 0, "CAN_COLLIDE"];
		_spawnLocation = (getPosATL _spawnMarker);

		// Spawn the vehicle at the marker position
		PVDZE_veh_Publish2 = [_spawnMarker, [ _direction, _spawnLocation], _vehicleClassname, false, _vehicleKey, _player];
		publicVariableServer  "PVDZE_veh_Publish2";

		PVDZE_veh_Init = nil; // Dirty hack
		PVDZE_veh_Publish2 spawn server_publishVeh2; // TEMP: DayZ Epoch Live Editor Code, remove for release

		// This feels dirty, possibly only needed for local dev. Swap for addPublicVariableEventHandler
		waitUntil {!isNil "PVDZE_veh_Init"};
		_newObjectUID = PVDZE_veh_Init getVariable["ObjectUID", 0];

		// Update the policy data table with the new ObjectUID
		_key = format ["UPDATE `mf_insurance_policy_data` SET ObjectUID = '%1' WHERE ObjectUID = '%2';", _newObjectUID, _originalObjectUID];
		_result = _key call server_hiveReadWrite;
		diag_log ("HIVE: WRITE: Set Recovered Vehicle ObjectUID: " + str(_key) );
		diag_log ("HIVE: RESULT: Set Recovered Vehicle ObjectUID: " + str(_result) );
		_key = nil;
		_result = nil;

		_player reveal _spawnMarker;
		cutText[format["Successfully recovered %1. %2 added to your toolbelt.", _vehicleName, _vehicleKey],"PLAIN DOWN"];
	};
} 
else {
	cutText [ format["Cannot recover %1. Key cannot be added to your toolbelt because it is full.", _vehicleName], "PLAIN DOWN"];
};

DZE_ActionInProgress = false;