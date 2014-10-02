/**
 * mf-insurance/action_makePayment.sqf
 * Makes insurance payment(s) for a player insured vehicle.
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 0.1.0
 * MIT Licence
 **/

private ["_player", "_vehicleClassname", "_vehicleName", "_insuranceData", "_insuranceCurrencyClassname", "_insuredID", "_paymentQty", "_dialog"];

disableSerialization;

_player = player;

_vehicleClassname = MF_Insurance_Current_Item select 0 select 0;
_vehicleName = MF_Insurance_Current_Item select 0 select 1;

_insuranceData = MF_Insurance_Current_Item select 1;
_insuranceCurrencyClassname = call compile (_insuranceData select 2) select 1;
_insuredID = _insuranceData select 4;
_paymentQty = ({_x == _insuranceCurrencyClassname} count (magazines _player));

_dialog = findDisplay MF_Insurance_iddDialog; // Get a reference to the display
_dialog closeDisplay 9000;

// Check that the player has at least one of the required currency for payment
if(_paymentQty > 0) then {
	private ["_animState", "_started", "_finished", "_isMedic"];

	if(DZE_ActionInProgress) exitWith { 
		cutText["Payment for insured vehicle already in progress." , "PLAIN DOWN"]; 
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

	// Animation has finished, begin making payment
	if (_finished) then {
		private ["_key", "_result"];

		// Take the payment from the player
		[_player, _insuranceCurrencyClassname, _paymentQty] call BIS_fnc_invRemove;

		// Add a payment record to the payments table
		_key = format ["INSERT INTO `mf_insurance_payments` (`InsuredID`, `PaymentClassname`, `PaymentQty`) VALUES ('%1', '%2', '%3');", _insuredID, _insuranceCurrencyClassname, _paymentQty];
		_result = _key call server_hiveReadWrite;
		diag_log ("HIVE: WRITE: Create payment record: " + str(_key) );
		_key = nil;
		_result = nil;

		cutText[format["Payment of %1 %2 for %3 insurance was successful.", _paymentQty, _insuranceCurrencyClassname, _vehicleName], "PLAIN DOWN"];
	};
} 
else {
	cutText[format["Cannot make insurance payment. You do not have any %1 in your inventory.", _insuranceCurrencyClassname], "PLAIN DOWN"];
};

DZE_ActionInProgress = false;