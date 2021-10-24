// private _fnc_scriptName = "TRGM_CLIENT_fnc_setNVG";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


if (TRGM_VAR_iAllowNVG isEqualTo 0) then {
    player addPrimaryWeaponItem "acc_flashlight";
    player enableGunLights "forceOn";
    {player unassignItem _x; player removeItem _x;} forEach TRGM_VAR_aNVClassNames;
};