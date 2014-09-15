/**
 * mf-insurance/player_mfInsuranceDialog.sqf
 * Displays the vehicle insurance dialog, populating the vehicle list with insured vehicles and
 * uninsured owned vehicles that are near by. 
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 0.1.0
 * MIT Licence
 **/

private ["_dialog", "_vehicleFilters", "_playerUID"];

disableSerialization;

_player = player;

//_playerUID = getPlayerUID _player; // Use this for real releases.
_playerUID = _player getVariable ["playerUID", 0]; // TEMP for DayZ Epoch Live Editor


_vehicleFilters = [
	["AllVehicles", "All"],
	["Air", "Air"],
	["Land", "Land"],
	["Sea", "Sea"]
];

MF_Insurance_iddDialog = 1000;

MF_Insurance_idcFilterComboBox = 2100;
MF_Insurance_idcDialogList = 1500;

MF_Insurance_idcVehicleTitle = 1005;
MF_Insurance_idcVehicleImage = 1200;

MF_Insurance_idcVehicleInfo_Pane = 1801;
MF_Insurance_idcVehicleInfo_Status = 1001;
MF_Insurance_idcVehicleInfo_Cost = 1002;
MF_Insurance_idcVehicleInfo_PaymentFrequency = 1003;
MF_Insurance_idcVehicleInfo_Balance = 1004;
MF_Insurance_idcVehicleInfo_PaymentDueDate = 1000;

MF_Insurance_idcBtnRemove = 1702;
MF_Insurance_idcBtnRecover = 1703;
MF_Insurance_idcBtnPay = 1701;
MF_Insurance_idcBtnInsure = 1704;

// Functions
MF_Insurance_Vehcile_Get_Insurance_Policy =
{
	private ["_vehicle", "_result"];
	_vehicle = _this;
	_result = [];

	{
		if( typeOf _vehicle == (_x select 0) ) exitWith {
			_result = _x;
		};
	} forEach call MF_Insurance_Policy_Config_Array;

	_result
};


MF_Insurance_Get_Player_Keys =
{
	private ["_itemsPlayer", "_tempKeys", "_tempKeysNames", "_keyColours", "_ownerKeyId", "_ownerKeyName"];

	_itemsPlayer = items player;
	_tempKeys = [];
	_tempKeysNames = [];
	_keyColours = ["ItemKeyYellow","ItemKeyBlue","ItemKeyRed","ItemKeyGreen","ItemKeyBlack"];

	// find available keys on the player
	{
		if (configName(inheritsFrom(configFile >> "CfgWeapons" >> _x)) in _keyColours) then {
			_ownerKeyId = getNumber(configFile >> "CfgWeapons" >> _x >> "keyid");
			_ownerKeyName = getText(configFile >> "CfgWeapons" >> _x >> "displayName");
			_tempKeysNames set [_ownerKeyId, _ownerKeyName];
			_tempKeys set [count _tempKeys, str(_ownerKeyId)];
		};
	} forEach _itemsPlayer;

	_tempKeys
};


MF_Insurance_Get_Nearby_Owned_Vehicles =
{
	private ["_nearestVehicles", "_nearestOwnedVehicles", "_ownerID", "_hasKey", "_playerKeys"];

	_nearestVehicles = [];
	_nearestOwnedVehicles = [];
	_playerKeys = [] call MF_Insurance_Get_Player_Keys;
	_nearestVehicles = nearestObjects [player, ["Land", "Air", "Ship"], 10];

	{
		_ownerID = _x getVariable ["CharacterID", "0"];
		_hasKey = _ownerID in _playerKeys;

		if( _ownerID != "0" && _hasKey ) then {
			_nearestOwnedVehicles set [count _nearestOwnedVehicles, _x];
		};

	} forEach _nearestVehicles;

	_nearestOwnedVehicles
};

MF_Insurance_Get_Player_Insured_Vehicles =
{
	private ["_key", "_result", "_insuredVehiclesArray"];
	// Get the player's policy ID from the database
	_key = format ["SELECT mf_insurance_policy_data.ObjectUID, mf_insurance_policy_data.Classname, mf_insurance_policy_data.CharacterID, mf_insurance_policy_data.InsuranceAmount, mf_insurance_policy_data.Frequency FROM `mf_insurance_policy_data` LEFT JOIN `mf_insurance_policy` ON mf_insurance_policy_data.PolicyID = mf_insurance_policy.PolicyID WHERE mf_insurance_policy.PlayerUID = '%1';", _playerUID];
	_result = _key call server_hiveReadWrite;
	diag_log ("HIVE: READ: Get player insured vehicles: " + str(_key) );
	diag_log ("HIVE: RESULT: Get player insured vehicles: " + str(_result) );
	
	_insuredVehiclesArray = _result select 0;
	_key = nil;
	_result = nil;

	_insuredVehiclesArray
};

MF_Insurance_Get_Vehicle_Data = 
{
	private ["_vehicle", "_cfgVehicles", "_vehicleName", "_vehicleImage", "_vehicleInfo", "_insuranceInfo"];
	_vehicle = _this select 0;

	switch(typeName _vehicle) do {
		case "OBJECT": {
			_cfgVehicles = configFile >> "cfgVehicles" >> TypeOf(_vehicle);
		};
		case "STRING": {
			_cfgVehicles = configFile >> "cfgVehicles" >> _vehicle
		};
	};

	_vehicleName = getText(_cfgVehicles >> "displayName");
	_vehicleImage = getText(_cfgVehicles >> "picture");
	_vehicleInfo = [_vehicle, _vehicleName, _vehicleImage];
	_insuranceInfo = []; // TODO: populate this with data from the database.

	[_vehicleInfo, _insuranceInfo]
};

MF_Insurance_Load_Vehicle_List = 
{
	private ["_typeIndex", "_type"];
	_typeIndex = lbCurSel MF_Insurance_idcFilterComboBox;
	_type = lbData [MF_Insurance_idcFilterComboBox, _typeIndex];

	lbClear MF_Insurance_idcDialogList;

	// Populate the dialog list with data
	{
		private ["_vehicle", "_vehicleName", "_index"];
		_vehicle = _x select 0 select 0;
		_vehicleName = _x select 0 select 1;

		if( _vehicle isKindOf _type ) then {
			_index = lbAdd [MF_Insurance_idcDialogList, format["%1", _vehicleName]];
		};
		
	} forEach mfInsuranceVehicleList;
};

MF_Insurance_Dialog_Event_List_Item_Change = 
{
	private ["_index", "_item", "_handle"];
	_index = _this select 1;
	_item = mfInsuranceVehicleList select _index;

	_handle = _item execVM format["%1\displayVehicleData.sqf", MF_Insurance_Base_Path];
};

MF_Insurance_Hide_Vehicle_Data_Panel =
{
	ctrlShow [MF_Insurance_idcVehicleTitle, false];
	ctrlShow [MF_Insurance_idcVehicleImage, false];

	ctrlShow [MF_Insurance_idcVehicleInfo_Pane, false];
	ctrlShow [MF_Insurance_idcVehicleInfo_Status, false];
	ctrlShow [MF_Insurance_idcVehicleInfo_Cost, false];
	ctrlShow [MF_Insurance_idcVehicleInfo_PaymentFrequency, false];
	ctrlShow [MF_Insurance_idcVehicleInfo_Balance, false];
	ctrlShow [MF_Insurance_idcVehicleInfo_PaymentDueDate, false];

	ctrlShow [MF_Insurance_idcBtnRemove, false];
	ctrlShow [MF_Insurance_idcBtnRecover, false];
	ctrlShow [MF_Insurance_idcBtnPay, false];
	ctrlShow [MF_Insurance_idcBtnInsure, false];
};

// >>>>>>>>>>>>>>>>> Initiate the dialog <<<<<<<<<<<<<<<<<<<

if( isNil "mfInsuranceVehicleList" ) then {
	private ["_vehicleData", "_nearbyOwnedVehicles", "_playerInsuredVehicles", "_playerInsuredVehiclesObjectUIDs"];

	titleText ["Loading MF-Insurance dialog...", "PLAIN DOWN"];

	mfInsuranceVehicleList = [];
	_playerInsuredVehiclesObjectUIDs = [];

	_nearbyOwnedVehicles = call MF_Insurance_Get_Nearby_Owned_Vehicles;
	_playerInsuredVehicles = call MF_Insurance_Get_Player_Insured_Vehicles;

	// Get all of the insured vehicles ObjectUID's
	{
		private["_objectUID"];

		_objectUID = _x select 0;
		_playerInsuredVehiclesObjectUIDs set [count(_playerInsuredVehiclesObjectUIDs), _objectUID];
	} forEach _playerInsuredVehicles;

	//Insured vehicles and add them to the vehicle list
	{
		if( typeName _x == "ARRAY") then {
			_vehicleData = [(_x select 1)] call MF_Insurance_Get_Vehicle_Data;
			mfInsuranceVehicleList set [(count mfInsuranceVehicleList), _vehicleData];
		};
	} forEach _playerInsuredVehicles;

	//Nearby owned vehicles, filtering out already insured vehicles, and add them to the vehicle list
	{
		private["_objectUID"];

		_objectUID = _x getVariable["ObjectUID", 0];

		if( alive _x && player != _x && !(_objectUID in _playerInsuredVehiclesObjectUIDs) ) then {
			_vehicleData = [_x] call MF_Insurance_Get_Vehicle_Data;
			mfInsuranceVehicleList set [(count mfInsuranceVehicleList), _vehicleData];
		};
	} forEach _nearbyOwnedVehicles;
};

titleFadeOut 2;	
createDialog "MFInsuranceDialog";

_dialog = findDisplay MF_Insurance_iddDialog; // Get a reference to the display

// Clear the fields
lbClear MF_Insurance_idcFilterComboBox;
[] call MF_Insurance_Hide_Vehicle_Data_Panel;

// Populate the filter list
{
	private ["_filter", "_text", "_index"];
	_filter = _x select 0;
	_text = _x select 1;

	_index = lbAdd [MF_Insurance_idcFilterComboBox, format["%1", _text]];
			 lbSetData [MF_Insurance_idcFilterComboBox, _index, _filter];
} forEach _vehicleFilters;

lbSetCurSel [MF_Insurance_idcFilterComboBox, 0];
[] call MF_Insurance_Load_Vehicle_List;

// Add an event handler to the vehicle list which fires when the selected item changes.
(_dialog displayCtrl MF_Insurance_idcDialogList) ctrlAddEventHandler ["LBSelChanged", "[] call MF_Insurance_Hide_Vehicle_Data_Panel; _this call MF_Insurance_Dialog_Event_List_Item_Change"]; 
(_dialog displayCtrl MF_Insurance_idcFilterComboBox) ctrlAddEventHandler ["LBSelChanged", "[] call MF_Insurance_Load_Vehicle_List;"]; 

waitUntil { !dialog };

mfInsuranceVehicleList = nil;