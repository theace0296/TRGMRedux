// private _fnc_scriptName = "TRGM_CLIENT_fnc_postStartMissionCamera";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


params ["_isHiddenObj", "_bMoveToAO"];


if (hasInterface && {!((player getVariable ["TRGM_postStartMissionCamRunning", "NOTRUN"]) isEqualTo "COMPLETE")}) then {
    player setVariable ["TRGM_postStartMissionCamRunning", "RUNNING", true];
    private _locationText = [TRGM_VAR_ObjectivePositions select 0] call TRGM_GLOBAL_fnc_getLocationName;
    private _hour = floor daytime;
    private _minute = floor ((daytime - _hour) * 60);

    private _strHour = str(_hour);
    private _strMinute = str(_minute);
    private _lenHour = count (_strHour);
    private _lenMin = count (_strMinute);
    if (_lenHour isEqualTo 1) then {
        _strHour = format["0%1",_strHour];
    };
    if (_lenMin isEqualTo 1) then {
        _strMinute = format["0%1",_strMinute];
    };
    private _time24 = text format ["%1:%2",_strHour,_strMinute];

    if (!isDedicated) then {
        sleep 5;
    };


    private _LineOne = format [localize "STR_TRGM2_StartMission_Day",str(TRGM_VAR_iCampaignDay)];
    private _LineTwo = (localize "STR_TRGM2_StartMission_Mission") + TRGM_VAR_CurrentZeroMissionTitle;
    private _LineThree = _locationText;
    private _LineFour = (localize "STR_TRGM2_StartMission_Time") + str(_time24);

    if (_isHiddenObj) then {
        _LineTwo = (localize "STR_TRGM2_StartMission_Mission") + (localize "STR_TRGM2_StartMission_MissionUnknown");
        _LineThree = localize "STR_TRGM2_StartMission_LocationUnknown";
    };

    if (!(TRGM_VAR_iMissionIsCampaign)) then {
        _LineOne = localize "STR_TRGM2_Description_Name";
    };

    if (TRGM_VAR_MaxBadPoints >= 10) then {
        titleText ["", "BLACK IN", 5];
        _LineTwo = (localize "STR_TRGM2_StartMission_Final") + TRGM_VAR_CurrentZeroMissionTitle;
        //titleText [format["Day %1 - %2\nFinal Objective: %3\nLocation: %4",TRGM_VAR_iCampaignDay,_time24,TRGM_VAR_CurrentZeroMissionTitle,_locationText], "BLACK IN", 5];
    }
    else {
        titleText ["", "BLACK IN", 5];
        //titleText [format["Day %1 - %2.\nObjective: %3\nLocation: %4",TRGM_VAR_iCampaignDay,_time24,TRGM_VAR_CurrentZeroMissionTitle,_locationText], "BLACK IN", 5];
    };

    ace_hearing_disableVolumeUpdate = true;

    playMusic "";
    0 fadeMusic 1;
    if (isNil "TRGM_VAR_NewMissionMusic") then {TRGM_VAR_NewMissionMusic = selectRandom TRGM_VAR_ThemeAndIntroMusic; publicVariable "TRGM_VAR_NewMissionMusic";};
    playMusic TRGM_VAR_NewMissionMusic;
    format["StartMission Music: %1", TRGM_VAR_NewMissionMusic] call TRGM_GLOBAL_fnc_log;

    private _txt1Layer = "txt1" call BIS_fnc_rscLayer;
    private _txt2Layer = "txt2" call BIS_fnc_rscLayer;


    private _texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.6' color='#ffffff'>" + _LineTwo +"</t>";
    [_texta, 0, 0.220, 7, 1,0,_txt1Layer] spawn BIS_fnc_dynamicText;


    private _txt5Layer = "txt5" call BIS_fnc_rscLayer;
    private _txt6Layer = "txt6" call BIS_fnc_rscLayer;


    _texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.8' color='#Ffffff'>" + _LineOne +"</t>";
    [_texta, -0, 0.150, 7, 1,0,_txt5Layer] spawn BIS_fnc_dynamicText;

    _texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.8' color='#Ffffff'>" + (TRGM_VAR_AdvancedSettings select TRGM_VAR_ADVSET_GROUP_NAME_IDX) + "</t>";
    [_texta, -0, 0.350, 7, 1,0,_txt6Layer] spawn BIS_fnc_dynamicText;

    showcinemaborder true;

    private _pos1 = nil;
    private _pos2 = nil;
    if (_bMoveToAO) then {
        _pos1 = (TRGM_VAR_AOCampPos getPos [(floor(random 100))+50, (floor(random 360))]);
        _pos2 = (TRGM_VAR_AOCampPos getPos [(floor(random 100))+50, (floor(random 360))]);
    }
    else {
        _pos1 = (player getPos [(floor(random 100))+50, (floor(random 360))]);
        _pos2 = (player getPos [(floor(random 100))+50, (floor(random 360))]);
    };
    _pos1 = [_pos1 select 0,_pos1 select 1,selectRandom[10,20]];
    _pos2 = [_pos2 select 0,_pos2 select 1,selectRandom[10,20]];


    private _camera = "camera" camCreate _pos1;
    player setVariable ["TRGM_postStartMissionCam", _camera, true];
    _camera cameraEffect ["internal","back"];

    _camera camPreparePos _pos2;
    if (_bMoveToAO) then {
        _camera camPrepareTarget TRGM_VAR_AOCampPos;
    }
    else {
        _camera camPrepareTarget player;
    };
    _camera camPrepareFOV 0.4;
    _camera camCommitPrepared 46;

    sleep 3;
    any= [_LineThree,_LineFour]spawn BIS_fnc_infotext;

    sleep 3;
    titleCut ["", "BLACK out", 5];

    getNumber(configfile >> "CfgMusic" >> TRGM_VAR_NewMissionMusic >> "duration") fadeMusic 0;
    [] spawn {
        sleep getNumber(configfile >> "CfgMusic" >> TRGM_VAR_NewMissionMusic >> "duration");
        ace_hearing_disableVolumeUpdate = false;
        playMusic "";
    };
    sleep 3;

    player setVariable ["TRGM_postStartMissionCamRunning", "ENDING", true];
};

true;