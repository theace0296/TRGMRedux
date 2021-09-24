// private _fnc_scriptName = "TRGM_CLIENT_fnc_selectAOLocation";
params[["_player", objNull, [objNull]]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (_player != player) exitWith {false;};

if ((call TRGM_CLIENT_fnc_isAdmin) && (isNil "TRGM_VAR_AdminPlayer" || isNull TRGM_VAR_AdminPlayer)) then {
    TRGM_VAR_AdminPlayer = player; publicVariable "TRGM_VAR_AdminPlayer";
};

if (TRGM_VAR_AdminPlayer isEqualTo player) then {
    TRGM_VAR_foundManualAOPos = [0,0,0]; publicVariable "TRGM_VAR_foundManualAOPos";
    TRGM_VAR_ManualAOPosFound = false; publicVariable "TRGM_VAR_ManualAOPosFound";
    if (!TRGM_VAR_ManualAOPosFound) then {
        TRGM_VAR_playerIsChoosingManualAOPos = true; publicVariable "TRGM_VAR_playerIsChoosingManualAOPos";
        TRGM_VAR_MapClicked = 0; publicVariable "TRGM_VAR_MapClicked";

        OnMapSingleClick "TRGM_VAR_ClickedPos = _pos; TRGM_VAR_MapClicked = 1; publicVariable ""TRGM_VAR_MapClicked""";
        openMap [true, false];
        hintC (localize "STR_TRGM2_tele_SelectPositionAO");

        while {true} do {
            if (TRGM_VAR_MapClicked isEqualTo 1) then { // player has clicked the map
                OnMapSingleClick "TRGM_VAR_MapClicked = 2; publicVariable ""TRGM_VAR_MapClicked""";
                hintC (localize "STR_TRGM2_InitClickValidPos");
                private _ManualAOPosMarker = createMarker [format ["%1", random 10000], TRGM_VAR_ClickedPos];
                _ManualAOPosMarker  setMarkerShape "ICON";
                _ManualAOPosMarker  setMarkerType "hd_dot";
                _ManualAOPosMarker  setMarkerSize [5,5];
                _ManualAOPosMarker  setMarkerColor "ColorRed";
                _ManualAOPosMarker  setMarkerText "AO";
                waitUntil { sleep 1; ((TRGM_VAR_MapClicked isEqualTo 2) || !visibleMap); };
                deleteMarker _ManualAOPosMarker;
                if (TRGM_VAR_MapClicked isEqualTo 2) then {
                    TRGM_VAR_MapClicked = 0; publicVariable "TRGM_VAR_MapClicked";
                    OnMapSingleClick "TRGM_VAR_ClickedPos = _pos; TRGM_VAR_MapClicked = 1; publicVariable ""TRGM_VAR_MapClicked""";
                } else {
                    onMapSingleClick "";
                    openMap [false, false];
                    TRGM_VAR_foundManualAOPos = TRGM_VAR_ClickedPos; publicVariable "TRGM_VAR_foundManualAOPos";
                    TRGM_VAR_ManualAOPosFound = true; publicVariable "TRGM_VAR_ManualAOPosFound";
                };
            };
            sleep 5;
            if (TRGM_VAR_ManualAOPosFound) exitwith {true;};
            if !(visibleMap) then {openMap [true, false]; hintC (localize "STR_TRGM2_tele_SelectPositionAO");};
        };
    };
};

true;