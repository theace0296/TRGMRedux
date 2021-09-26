// private _fnc_scriptName = "TRGM_GLOBAL_fnc_populateLoadingWait";
params ["_percentage", ["_useCampaignLoading", false]];
if (isNil "TRGM_VAR_PopulateLoadingWait_percentage") then { TRGM_VAR_PopulateLoadingWait_percentage = 0; publicVariable "TRGM_VAR_PopulateLoadingWait_percentage"; };

if !(isServer) exitWith {};

sleep 0.1;

if (TRGM_VAR_PopulateLoadingWait_percentage > 100) exitWith {};

TRGM_VAR_PopulateLoadingWait_percentage = 5 + TRGM_VAR_PopulateLoadingWait_percentage;
if (TRGM_VAR_PopulateLoadingWait_percentage >= 100) then {
    TRGM_VAR_PopulateLoadingWait_percentage = 100;
};

if !(isNil "_percentage") then {
    TRGM_VAR_PopulateLoadingWait_percentage = _percentage;
};

TRGM_VAR_PopulateLoadingWait_percentage = ceil(TRGM_VAR_PopulateLoadingWait_percentage);
publicVariable "TRGM_VAR_PopulateLoadingWait_percentage";

private _message = ["Generating mission please wait...", "Generating new mission please wait..."] select (_useCampaignLoading);

[format["%1 %2 percent", _message, TRGM_VAR_PopulateLoadingWait_percentage], {TRGM_VAR_PopulateLoadingWait_percentage <= 100}, 100] call TRGM_GLOBAL_fnc_notifyGlobal;

if (TRGM_VAR_PopulateLoadingWait_percentage >= 100) then {
    TRGM_VAR_PopulateLoadingWait_percentage = 101; publicVariable "TRGM_VAR_PopulateLoadingWait_percentage";
};

true;