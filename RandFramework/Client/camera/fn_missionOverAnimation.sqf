// private _fnc_scriptName = "TRGM_CLIENT_fnc_missionOverAnimation";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

sleep 60;
waitUntil {sleep 30; TRGM_VAR_AllInitScriptsFinished};
sleep 60;
private _bEnd = false;
while {!_bEnd} do {
    private _bMissionEndedAndPlayersOutOfAO = false;
    private _bMissionEnded = false;
    private _bAnyPlayersInAOAndAlive = false;

    if (TRGM_VAR_iMissionIsCampaign) then {
        private _dCurrentRep = [TRGM_VAR_MaxBadPoints - TRGM_VAR_BadPoints,1] call BIS_fnc_cutDecimals;
        if (TRGM_VAR_ActiveTasks call FHQ_fnc_ttAreTasksCompleted && _dCurrentRep >= 10 && TRGM_VAR_FinalMissionStarted) then {_bMissionEnded = true};
    }
    else {
        if (TRGM_VAR_ActiveTasks call FHQ_fnc_ttAreTasksCompleted) then {_bMissionEnded = true};
    };

    private _justPlayers = allPlayers - entities "HeadlessClient_F";
    {
        private _currentPlayer = _x;
        {
            if (alive(_currentPlayer) && _currentPlayer distance _x < 2000) then {
                _bAnyPlayersInAOAndAlive = true;
            };
        } forEach TRGM_VAR_ObjectivePositions;
    } forEach _justPlayers;
    if (_bMissionEnded && !_bAnyPlayersInAOAndAlive) then {_bMissionEndedAndPlayersOutOfAO = true};
    if (_bMissionEndedAndPlayersOutOfAO) then {
        _bEnd = true;
        ace_hearing_disableVolumeUpdate = true;
        2 fadeSound 0.1;
        playMusic "";
        0 fadeMusic 1;
        playMusic selectRandom TRGM_VAR_ThemeAndIntroMusic;
        //[format["InitPlayer Music: %1",TRGM_VAR_ThemeAndIntroMusic]] call TRGM_GLOBAL_fnc_notify;
        sleep 8;
        ["<t font='PuristaMedium' align='center' size='2.9' color='#ffffff'>" + localize "STR_TRGM2_Description_Name" + "</t><br/><t font='PuristaMedium' align='center' size='1' color='#ffffff'>" + localize "STR_TRGM2_TRGMInitPlayerLocal_TRGM2Title" + "</t>",-1,0.2,6,1,0,789] spawn BIS_fnc_dynamicText;
        sleep 10;
        ["<t font='PuristaMedium' align='center' size='2.9' color='#ffffff'>" + (call TRGM_GETTER_fnc_sGroupName) + "</t><br/><t font='PuristaMedium' align='center' size='1' color='#ffffff'><br />" + localize "STR_TRGM2_TRGMInitPlayerLocal_RTBDebreif" + "</t>",-1,0.2,6,1,0,789] spawn BIS_fnc_dynamicText;
        sleep 10;
        private _stars = "";
        private _iCount = 0;
        {
            _iCount = _iCount + 1;
            if (_iCount isEqualTo count allPlayers) then {
                _stars = _stars + name _x; // format [_stars,name _x, "|%2"];
            }
            else {
                _stars = _stars + name _x + " | "; // format [_stars,name _x, "|%2"];
            };
        } forEach allPlayers;
        [format ["<t font='PuristaMedium' align='center' size='2.9' color='#ffffff'>%2</t><br/><t font='PuristaMedium' align='center' size='1' color='#ffffff'><br />%1</t>",_stars, localize "STR_TRGM2_TRGMInitPlayerLocal_TRGM2Starring"],-1,0.2,6,1,0,789] spawn BIS_fnc_dynamicText;

        sleep 10;
        8 fadeMusic 0;
        8 fadeSound 1;
        [] spawn {
            sleep 8;
            ace_hearing_disableVolumeUpdate = false;
            playMusic "";
        };
    };
};