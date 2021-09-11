format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

disableSerialization;

if (isNil "TRGM_VAR_iMissionIsCampaign") then { TRGM_VAR_iMissionIsCampaign = false; publicVariable "TRGM_VAR_iMissionIsCampaign"; };

if (TRGM_VAR_iMissionIsCampaign) exitWith {};

if (isNil "TRGM_VAR_iMissionParamObjectives") exitWith {};

private _display = findDisplay 5000;

private _currentIndex = (count TRGM_VAR_iMissionParamObjectives) - 1;

if (_currentIndex isEqualTo 0) exitWith {
    _ctrl = (findDisplay 5000) displayCtrl 5500;
    _ctrl ctrlSetText ("Cannot remove first objective!");
    _ctrl ctrlShow true;
    [] spawn {
        disableSerialization;
        sleep 30;
        _ctrl = (findDisplay 5000) displayCtrl 5500;
        _ctrl ctrlShow false;
    };
};

private _startIdc = 5200 + (10 * _currentIndex);
private _objectiveControls = [_startIdc + 0, _startIdc + 1, _startIdc + 2, _startIdc + 3, _startIdc + 4];

{
    private _control = _display displayCtrl _x;
    ctrlDelete _control;
} forEach _objectiveControls;

TRGM_VAR_iMissionParamObjectives deleteAt _currentIndex;
publicVariable "TRGM_VAR_iMissionParamObjectives";

true;
