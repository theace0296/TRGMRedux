params[["_className", "", [objNull, ""]]];
// format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


switch (typeName _className) do {
    case ("OBJECT") : {_className = typeOf _className};
};

if !(isClass (configFile >> "CfgVehicles" >> _className)) exitWith {false};

// 8 Is a weapons squad, so anything that can hold a whole squad can be considered a transport.
// Unless it is a non-wheeled vehicle, then 6 allows for hueys and smaller helicopters to be considered transports.
if (_className isKindOf "Car") exitWith {
    getNumber(configFile >> "CfgVehicles" >> _className >> "transportSoldier") >= 8;
};
getNumber(configFile >> "CfgVehicles" >> _className >> "transportSoldier") >= 6;