// private _fnc_scriptName = "TRGM_SERVER_fnc_initMissionVars";

format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



sRiflemanToUse       = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sRiflemanMilitia);}; (call sRifleman); }; publicVariable "sRiflemanToUse";
sTeamleaderToUse     = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sTeamleaderMilitia);}; (call sTeamleader); }; publicVariable "sTeamleaderToUse";
sATManToUse          = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sATManMilitia);}; (call sATMan); }; publicVariable "sATManToUse";
sAAManToUse          = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sAAManMilitia);}; (call sAAMan); }; publicVariable "sAAManToUse";
sEngineerToUse       = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sEngineerMilitia);}; (call sEngineer); }; publicVariable "sEngineerToUse";
sGrenadierToUse      = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sGrenadierMilitia);}; (call sGrenadier); }; publicVariable "sGrenadierToUse";
sMedicToUse          = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sMedicMilitia);}; (call sMedic); }; publicVariable "sMedicToUse";
sMachineGunManToUse  = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sMachineGunManMilitia);}; (call sMachineGunMan); }; publicVariable "sMachineGunManToUse";
sSniperToUse         = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sSniperMilitia);}; (call sSniper); }; publicVariable "sSniperToUse";
sExpSpecToUse        = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sExpSpecMilitia);}; (call sExpSpec); }; publicVariable "sExpSpecToUse";
sEnemyHeliPilotToUse = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sEnemyHeliPilotMilitia);}; (call sEnemyHeliPilot); }; publicVariable "sEnemyHeliPilotToUse";

sTank1ArmedCarToUse  = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sTank1ArmedCarMilitia);}; (call sTank1ArmedCar); }; publicVariable "sTank1ArmedCarToUse";
sTank2APCToUse       = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sTank2APCMilitia);}; (call sTank2APC); }; publicVariable "sTank2APCToUse";
sTank3TankToUse      = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sTank3TankMilitia);}; (call sTank3Tank); }; publicVariable "sTank3TankToUse";
sAAAVehToUse         = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sAAAVehMilitia);}; (call sAAAVeh); }; publicVariable "sAAAVehToUse";
sMortarToUse         = { if (TRGM_VAR_ToUseMilitia_Side) exitWith {(call sMortarMilitia);}; (call sMortar); }; publicVariable "sMortarToUse";
true;
