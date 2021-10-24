// private _fnc_scriptName = "TRGM_CLIENT_fnc_missionSelectLoop";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


sleep 3;

while {!TRGM_VAR_bAndSoItBegins} do {
    if (TRGM_VAR_AdminPlayer isEqualTo player) then {
        if (!dialog) then {
            sleep 1.5;
            if  (!dialog && !TRGM_VAR_bOptionsSet) then { //seemed to show dialog twice... so havce added delay and double check its still not showing
                [] spawn TRGM_GUI_fnc_openDialogMissionSelection;
            };
        };
        sleep 0.5;
    } else {
        if (!TRGM_VAR_bOptionsSet && {!(TRGM_VAR_AdminPlayer isEqualTo player)}) then {
            private _txt1Layer = "txt1" call BIS_fnc_rscLayer;
            private _texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.5' color='#ffffff'>" + localize "STR_TRGM2_TRGMInitPlayerLocal_PleaseWait1 Admin " + localize "STR_TRGM2_TRGMInitPlayerLocal_PleaseWait2" + "</t>";
            [_texta, 0, 0.220, 7, 1,0,_txt1Layer] spawn BIS_fnc_dynamicText;
        } else {
            if (isNil "sl" && !isNull TRGM_VAR_AdminPlayer) then {
                private _txt5Layer = "txt5" call BIS_fnc_rscLayer;
                private _texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.8' color='#Ffffff'>" + localize "STR_TRGM2_TRGMInitPlayerLocal_TopSlotMustFilled" + "</t>";
                [_texta, -0, 0.150, 7, 1,0,_txt5Layer] spawn BIS_fnc_dynamicText;
            } else {
                if (!isPlayer sl && !isNull TRGM_VAR_AdminPlayer) then {
                    private _txt5Layer = "txt5" call BIS_fnc_rscLayer;
                    private _texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.8' color='#Ffffff'>" + localize "STR_TRGM2_TRGMInitPlayerLocal_TopSlotMustPlayer" + "</t>";
                    [_texta, -0, 0.150, 7, 1,0,_txt5Layer] spawn BIS_fnc_dynamicText;
                } else {
                    private _txt1Layer = "txt1" call BIS_fnc_rscLayer;
                    private _texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.5' color='#ffffff'>" + localize "STR_TRGM2_TRGMInitPlayerLocal_PleaseWait1 Admin " + localize "STR_TRGM2_TRGMInitPlayerLocal_PleaseWait3" + "</t>";
                    [_texta, 0, 0.220, 7, 1,0,_txt1Layer] spawn BIS_fnc_dynamicText;
                };
            };
        };
    };
};

