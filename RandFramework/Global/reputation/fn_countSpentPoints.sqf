// private _fnc_scriptName = "TRGM_GLOBAL_fnc_countSpentPoints";

format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


if (isNil "TRGM_VAR_SpawnedVehicles") then {TRGM_VAR_SpawnedVehicles = []; publicVariable "TRGM_VAR_SpawnedVehicles";};
private _SpentCount = 0;
{
   if ((side _x) isEqualTo TRGM_VAR_FriendlySide) then
   {
           //_SpawnedUnit setVariable ["RepCost", 1];
           private _var = _x getVariable "RepCost";
           if (!(isNil "_var")) then {
               _SpentCount = _SpentCount + _var;
           };
   };
} forEach allUnits + TRGM_VAR_SpawnedVehicles;
_SpentCount