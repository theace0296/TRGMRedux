params[["_className", "", [objNull, ""]]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

switch (typeName _className) do {
    case ("OBJECT") : {_className = typeOf _className};
};

if !(isClass (configFile >> "CfgVehicles" >> _className)) exitWith {false};

_configPath = (configFile >> "CfgVehicles" >> _className);

_isArmed = false;

if (_className isKindOf "CAManBase") then {
    _isArmed = count ((getArray(_configPath >> "Weapons")) - ["Throw","Put","FakeWeapon"]) > 0;
} else {
    if (_className isKindOf "AllVehicles") then {
        private _acceptedTurretNames = ["copilot", "crew chief", "door gunner", "passenger", "left door gunner", "right door gunner", "left gunner", "right gunner", "passenger (left seat)", "passenger (right seat)"];
        private _allTurrets = [_className, false] call BIS_fnc_allTurrets;
        private _allTurretGunnerNames = _allTurrets apply { toLower getText(([_className, _x] call BIS_fnc_turretConfig) >> "gunnerName") };
        _isArmed = count (_allTurretGunnerNames - _acceptedTurretNames) > 0;

        if (!_isArmed) then {
            private _nonWeapons = ["truckhorn","truckhorn2","sportcarhorn","laserdesignator_mounted","cmflarelauncher","cmflarelauncher_triples","laserdesignator_pilotcamera","vn_v_launcher_m18r","vn_v_launcher_m127","vn_v_launcher_m61","vn_v_launcher_m7"];
            _isArmed = count (_configPath >> "Components" >> "TransportPylonsComponent" >> "Pylons") > 0 || count ((getArray(_configPath >> "Weapons") apply {toLower _x}) - _nonWeapons) > 0;

            if (!_isArmed) then {
                if (_className isKindOf "Plane") then {
                    // Check for any turrets with weapons
                    {
                        _isArmed = count ((getArray(_configPath >> "Turrets" >> _x >> "Weapons") apply {toLower _x}) - _nonWeapons) > 0;
                        if (_isArmed) exitWith {};
                    } foreach (getArray(_configPath >> "Turrets"));
                } else {
                    {
                        private _turretName = getText(_configPath >> "Turrets" >> _x >> "gunnerName");
                        if !(_turretName in _acceptedTurretNames) then {
                            _isArmed = count (getArray(_configPath >> "Turrets" >> _x >> "Magazines")) > 0;
                        };
                        if (_isArmed) exitWith {};
                    } foreach (getArray(_configPath >> "Turrets"));
                };
            };
        };
    };
};

_isArmed;