params ["_civilian"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


//get armamanet assigned in entity-init
(_civilian getVariable "armament") params ["_gun","_magazine","_amount"];

_civilian addMagazines [_magazine,_amount];
_civilian addWeapon _gun;


true;