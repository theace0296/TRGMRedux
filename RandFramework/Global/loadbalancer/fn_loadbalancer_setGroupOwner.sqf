// private _fnc_scriptName = "TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner";
params [["_group", grpNull, [grpNull]]];
if (isNull _group) exitWith {};
if (({isPlayer _x} count units _group) > 0) exitWith {};
private _selectedClient = call TRGM_GLOBAL_fnc_loadbalancer_getHost;
_group setGroupOwner _selectedClient;
_group setVariable ["TRGM_VAR_groupClientOwner", _selectedClient];
{
    _x addEventHandler ["Local", {
        params ["_unit", "_isLocal"];
        if (_isLocal) then {
            group _unit setVariable ["TRGM_VAR_groupClientOwner", clientOwner, true];
        };
    }];
} forEach units _group;