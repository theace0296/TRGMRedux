// private _fnc_scriptName = "TRGM_GLOBAL_fnc_deleteTrash";
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



sleep 60;
hideBody (_this select 0);
sleep 5;
deleteVehicle (_this select 0);