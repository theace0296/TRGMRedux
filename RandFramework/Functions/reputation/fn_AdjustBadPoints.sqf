
//if (TREND_bDebugMode) then {hint format["Points adjusting: %1", TRGM_Logic getVariable "PointsUpdating"]};

if (!TREND_CoreCompleted) exitWith {};

sleep random [1,2.5,5]; //to increase the chance of not fireing at same time! (not convinsed that the "PointsUpdating" variable actually helped)


if (isNil { TRGM_Logic getVariable "PointsUpdating" }) then {
	TRGM_Logic setVariable ["PointsUpdating", false, true];
};

waitUntil {!(TRGM_Logic getVariable "PointsUpdating")};
TRGM_Logic setVariable ["PointsUpdating", true, true];

params ["_pointsToAdd","_message"];

_totalRep = [TREND_MaxBadPoints - TREND_BadPoints,1] call BIS_fnc_cutDecimals;

if (_totalRep > 0) then {
	TREND_BadPoints = TREND_BadPoints + _pointsToAdd;
	if (TREND_BadPoints > TREND_MaxBadPoints) then {
		TREND_BadPoints = TREND_MaxBadPoints;
	};
	publicVariable "TREND_BadPoints";
	TREND_BadPointsReason = TREND_BadPointsReason + format["<br /><t color='#ff0000'>%1 (-%2)</t>",_message,_pointsToAdd];
	publicVariable "TREND_BadPointsReason";
};

TRGM_Logic setVariable ["PointsUpdating", false, true];

TREND_BadPoints;