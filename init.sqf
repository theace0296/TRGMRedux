"Init.sqf" call TRGM_GLOBAL_fnc_log;

call TRGM_GLOBAL_fnc_initGlobalVars;

if (isServer) then {
   [] spawn {
      while {isNil "TRGM_VAR_AdminPlayer" || isNull TRGM_VAR_AdminPlayer} do {
         call TRGM_SERVER_fnc_setAdmin;
         sleep 30;
      };
   };
};

waitUntil { TRGM_VAR_playerIsChoosingHQpos || TRGM_VAR_NeededObjectsAvailable; };

if (isServer && !TRGM_VAR_NeededObjectsAvailable) then {
   waitUntil { TRGM_VAR_HQPosFound };
   _handle = [TRGM_VAR_foundHQPos] spawn TRGM_SERVER_fnc_createNeededObjects;
   waitUntil {scriptDone _handle};

   { [[_x], {(_this select 0) allowDamage false}] remoteExec ["call", _x]; } forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});

   waitUntil { sleep 10; TRGM_VAR_NeededObjectsAvailable; };

   {
      if (!isPlayer _x) then {
         _safePos = [TRGM_VAR_foundHQPos, 0,25,15,0,0.15,0,[],[[TRGM_VAR_foundHQPos select 0, TRGM_VAR_foundHQPos select 1],[TRGM_VAR_foundHQPos select 0, TRGM_VAR_foundHQPos select 1]]] call TRGM_GLOBAL_fnc_findSafePos;
         [[_x, _safePos], {
            (_this select 0) setpos (_this select 1);
            (_this select 0) setdamage 0;
            (_this select 0) allowDamage true;
         }] remoteExec ["call", _x];
      } else {
            [[_x], {
               titleCut ["", "BLACK OUT", 5];
               (_this select 0) setpos [(TRGM_VAR_foundHQPos select 0) - 10, (TRGM_VAR_foundHQPos select 1)];
               (_this select 0) setdamage 0;
               (_this select 0) allowDamage true;
               titleCut ["", "BLACK IN", 5];
            }] remoteExec ["call", _x];
      };
   } forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});
};

if (isServer) then {
    TRGM_VAR_FirstSpottedHasHappend = false; publicVariable "TRGM_VAR_FirstSpottedHasHappend";
};

tf_give_personal_radio_to_regular_soldier = true; publicVariable "tf_give_personal_radio_to_regular_soldier";
tf_no_auto_long_range_radio = true; publicVariable "tf_no_auto_long_range_radio";


call FHQ_fnc_ttiInit;
call FHQ_fnc_ttiPostInit;

[
   west,
      [(localize "STR_TRGM2_Init_Mission"), ""],
      ["", ""],
   east,
      ["", ""],
      ["", ""],
   {true},
      [(localize "STR_TRGM2_Init_TRGM2Engine"), (localize "STR_TRGM2_Init_Credits"), "Treendy, Redux by TheAce0296"],
      [(localize "STR_TRGM2_Init_TRGM2Engine"), (localize "STR_TRGM2_Init_ScriptsUsed"), localize "STR_TRGM2_TRGMSetUnitGlobalVars_ScriptsUsed"]
] call FHQ_fnc_ttAddBriefing;

"Marker1" setMarkerTextLocal (localize "STR_TRGM2_Init_MarkerText_HQ"); //Head Quarters marker localize
"transportChopper" setMarkerTextLocal (localize "STR_TRGM2_Init_MarkerText_TransportChopper"); //Transport Chopper marker localize

if (isServer) then {
   [laptop1, [localize "STR_TRGM2_openDialogRequests_RequestUnitsVehicles", {player call TRGM_GUI_fnc_openDialogRequests;}, [], 0, true, true, "", "_this isEqualTo player"]] remoteExec ["addAction", 0, true];
   [laptop1, [localize "STR_TRGM2_logMissionInfo", {player call TRGM_GLOBAL_fnc_copyMissionInfo;}, [], 0, true, true, "", "_this isEqualTo player"]] remoteExec ["addAction", 0, true];
   [] spawn TRGM_SERVER_fnc_main;
};

true;