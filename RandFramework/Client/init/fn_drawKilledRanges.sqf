format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};

if (getPlayerUID player in TRGM_VAR_KilledPlayers) then {
    {
        if (getPlayerUID player isEqualTo TRGM_VAR_KilledPlayers select _forEachIndex) then {
            //draw marker at TRGM_VAR_KilledPositions select _forEachIndex
            private _color = "ColorBlack";
            private _mrkPos = createMarkerLocal [format["mrkNoGoA%1",_forEachIndex], _x select 1];
            _mrkPos setMarkerShapeLocal "ELLIPSE";
            _mrkPos setMarkerSizeLocal [TRGM_VAR_KilledZoneRadius,TRGM_VAR_KilledZoneRadius];
            _mrkPos setMarkerColorLocal "ColorRed";
            _mrkPos setMarkerAlphaLocal 0.5;

            private _mrkPos2 = createMarkerLocal [format["mrkNoGoB%1",_forEachIndex], _x select 1];
            _mrkPos2 setMarkerShapeLocal "ELLIPSE";
            _mrkPos2 setMarkerSizeLocal [TRGM_VAR_KilledZoneInnerRadius,TRGM_VAR_KilledZoneInnerRadius];
            _mrkPos2 setMarkerColorLocal _color;
            _mrkPos2 setMarkerAlphaLocal 0.5;
        };

    } forEach TRGM_VAR_KilledPositions;
};