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
		 "_vehicleKey", "_isValidKey", "_hasKey", "_playerInventory", "_playerBackpack"];

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
	// Place a vehicle spawn marker (local)
	_spawnMarker = createVehicle ["Sign_arrow_down_large_EP1", _spawnLocation, [], 0, "CAN_COLLIDE"];
	_spawnLocation = (getPosATL _spawnMarker);

	// Spawn the vehicle at the marker position
	PVDZE_veh_Publish2 = [_spawnMarker, [ _direction, _spawnLocation], _vehicleClassname, false, _vehicleKey, _player];
	publicVariableServer  "PVDZE_veh_Publish2";

	PVDZE_veh_Publish2 spawn server_publishVeh2; // TEMP: DayZ Epoch Live Editor Code, remove for release
	_player reveal _spawnMarker;

	cutText[format["Successfully recovered %1. %2 added to your toolbelt.", _vehicleName, _vehicleKey],"PLAIN DOWN"];

	// TODO: Get the new ObjectUID for the spawned vehicle and update the db insurance records with the new uid.
	// Pull from the database based upon spawnLocation, Classname and CharacterID
} else {
	cutText [ format["Cannot recover %1. Key cannot be added to your toolbelt because it is full.", _vehicleName], "PLAIN DOWN"];
};