format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

disableSerialization;

if (isNil "TRGM_VAR_iMissionIsCampaign") then { TRGM_VAR_iMissionIsCampaign = false; publicVariable "TRGM_VAR_iMissionIsCampaign"; };

if (TRGM_VAR_iMissionIsCampaign) exitWith {};

if (isNil "TRGM_VAR_iMissionParamObjectives") exitWith {};

private _display = findDisplay 5000;

private _newIndex = count TRGM_VAR_iMissionParamObjectives;

if (_newIndex >= 8) exitWith {
    _ctrl = (findDisplay 5000) displayCtrl 5500;
    _ctrl ctrlSetText ("Already at maximum number of objectives!");
    _ctrl ctrlShow true;
    [] spawn {
        disableSerialization;
        sleep 30;
        _ctrl = (findDisplay 5000) displayCtrl 5500;
        _ctrl ctrlShow false;
    };
};

[_newIndex] call TRGM_GUI_fnc_createObjectiveGroup;

TRGM_VAR_iMissionParamObjectives pushBack [0, false, false, false];
publicVariable "TRGM_VAR_iMissionParamObjectives";

true;
