/*
 * Author: Trendy (Modified by TheAce0296)
 * Applies selected mission settings and sets
 * global variables signal the rest of the mission
 * to generate.
 *
 * Arguments:
 * 0 - Control that called this function. <CONTROL>
 * 1 - Savetype to load mission data from. <NUMBER> [Default: 0]
 *     0 = None, 1 = Local Load, 2 = Global Load
 *
 * Return Value:
 * true <BOOL>
 *
 * Example:
 * [_this, 1] spawn TRGM_GUI_fnc_setParamsAndBegin
 */

params["_thisBeginControl","_SaveType"]; //_SaveType optional, default 0  (1 is local load, 2 is global load)
if (isNil "_SaveType") then {_SaveType = 0};
if (_SaveType > 2) then {_SaveType = 0};

disableSerialization;
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


if (TRGM_VAR_ForceMissionSetup) then {
    TRGM_VAR_bAndSoItBegins =  true; publicVariable "TRGM_VAR_bAndSoItBegins";
    TRGM_VAR_bOptionsSet =  true; publicVariable "TRGM_VAR_bOptionsSet";
    closedialog 0;
}
else {
    if (_SaveType isEqualTo 0) then {
        _savePreviousSettings = [
            TRGM_VAR_iMissionIsCampaign,
            TRGM_VAR_iMissionParamObjectives,
            TRGM_VAR_iAllowNVG,
            TRGM_VAR_iMissionParamRepOption,
            TRGM_VAR_iWeather,
            TRGM_VAR_iUseRevive,
            TRGM_VAR_iStartLocation,
            TRGM_VAR_AdvancedSettings,
            TRGM_VAR_arrayTime,
            TRGM_VAR_IsFullMap
        ];
        profileNamespace setVariable [format ["%1:PreviousSettings:%2", worldname, TRGM_VAR_SaveDataVersion], _savePreviousSettings];
        saveProfileNamespace;

        TRGM_VAR_bOptionsSet =  true; publicVariable "TRGM_VAR_bOptionsSet";
        closedialog 0;
    };

    TRGM_VAR_sInitialSLPlayerID =  getPlayerUID player; publicVariable "TRGM_VAR_sInitialSLPlayerID"; //store the uid of the player picking the params at the start of a campaign, so when we save, we know the uid to save against even if he is killed!
    sleep 0.1;

    private _LoadVersion = "";
    if (_SaveType isEqualTo 1) then {
        _LoadVersion = worldName;
    };
    if (_SaveType isEqualTo 2) then {
        _LoadVersion = "GLOBAL";
    };

    if (_LoadVersion != "") then {
        TRGM_VAR_SaveTypeString =  _LoadVersion; publicVariable "TRGM_VAR_SaveTypeString";
        sleep 0.1;
        [[], {
            TRGM_VAR_SavedData = profileNamespace getVariable [TRGM_VAR_sInitialSLPlayerID + ":" + TRGM_VAR_SaveTypeString,[]]; //Get this from server only, but use player ID!!!
            publicVariable "TRGM_VAR_SavedData";
            //_ctrl ctrlSetText "SavedData: " + SavedData;
        }] remoteExec ["call", 2]; //Save this to server only
        sleep 0.1;

        if (count TRGM_VAR_SavedData isEqualTo 0 && {!(isNil "TRGM_VAR_InitialLoadedPreviousSettings") && {count TRGM_VAR_InitialLoadedPreviousSettings > 0}}) then {
            private _ctrl = (findDisplay 5000) displayCtrl 5500;
            _ctrl ctrlSetText (localize "STR_TRGM2_SetParamsAndBegin_ErrorMsg_NoData");
            _ctrl ctrlShow true;
            [] spawn {
                disableSerialization;
                sleep 10;
                _ctrl = (findDisplay 5000) displayCtrl 5500;
                _ctrl ctrlShow false;
            };
        } else {
            TRGM_VAR_InitialLoadedPreviousSettings params [
                ["_iMissionIsCampaign", true],
                ["_iMissionParamObjectives", [[0, false, false, false]]],
                ["_iAllowNVG", 2],
                ["_iMissionParamRepOption", 0],
                ["_iWeather", 1],
                ["_iUseRevive", 0],
                ["_iStartLocation", 2],
                ["_BadPoints", 0],
                ["_MaxBadPoints", 1],
                ["_BadPointsReason", ""],
                ["_iCampaignDay", 0],
                ["_AdvancedSettings", TRGM_VAR_DefaultAdvancedSettings],
                ["_arrayTime", [8, 15]],
                ["_IsFullMap", true]
            ];
            TRGM_VAR_iMissionIsCampaign      = _iMissionIsCampaign; publicVariable "TRGM_VAR_iMissionIsCampaign";
            TRGM_VAR_iMissionParamObjectives = _iMissionParamObjectives; publicVariable "TRGM_VAR_iMissionParamObjectives";
            TRGM_VAR_iAllowNVG               = _iAllowNVG; publicVariable "TRGM_VAR_iAllowNVG";
            TRGM_VAR_iMissionParamRepOption  = _iMissionParamRepOption; publicVariable "TRGM_VAR_iMissionParamRepOption";
            TRGM_VAR_iWeather                = _iWeather; publicVariable "TRGM_VAR_iWeather";
            TRGM_VAR_iUseRevive              = _iUseRevive; publicVariable "TRGM_VAR_iUseRevive";
            TRGM_VAR_iStartLocation          = _iStartLocation; publicVariable "TRGM_VAR_iStartLocation";
            TRGM_VAR_BadPoints               = _BadPoints; publicVariable "TRGM_VAR_BadPoints";
            TRGM_VAR_MaxBadPoints            = _MaxBadPoints; publicVariable "TRGM_VAR_MaxBadPoints";
            TRGM_VAR_BadPointsReason         = _BadPointsReason; publicVariable "TRGM_VAR_BadPointsReason";
            TRGM_VAR_iCampaignDay            = _iCampaignDay; publicVariable "TRGM_VAR_iCampaignDay";
            TRGM_VAR_AdvancedSettings        = _AdvancedSettings; publicVariable "TRGM_VAR_AdvancedSettings";
            TRGM_VAR_arrayTime               = _arrayTime; publicVariable "TRGM_VAR_arrayTime";
            TRGM_VAR_IsFullMap               = _IsFullMap; publicVariable "TRGM_VAR_IsFullMap";

            TRGM_VAR_SaveType =  _SaveType; publicVariable "TRGM_VAR_SaveType";

            TRGM_VAR_bAndSoItBegins = true; publicVariable "TRGM_VAR_bAndSoItBegins";
            TRGM_VAR_bOptionsSet = true; publicVariable "TRGM_VAR_bOptionsSet";
            closedialog 0;
        };
    };
};

TRGM_VAR_bOptionsSet = true; publicVariable "TRGM_VAR_bOptionsSet";

[format ["[[TRGM - DEBUG]] TRGM_VAR_iMissionIsCampaign     : %1", TRGM_VAR_iMissionIsCampaign]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_iMissionParamObjectives: %1", TRGM_VAR_iMissionParamObjectives]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_iAllowNVG              : %1", TRGM_VAR_iAllowNVG]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_iMissionParamRepOption : %1", TRGM_VAR_iMissionParamRepOption]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_iWeather               : %1", TRGM_VAR_iWeather]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_iUseRevive             : %1", TRGM_VAR_iUseRevive]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_iStartLocation         : %1", TRGM_VAR_iStartLocation]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_BadPoints              : %1", TRGM_VAR_BadPoints]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_MaxBadPoints           : %1", TRGM_VAR_MaxBadPoints]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_BadPointsReason        : %1", TRGM_VAR_BadPointsReason]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_iCampaignDay           : %1", TRGM_VAR_iCampaignDay]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_AdvancedSettings       : %1", TRGM_VAR_AdvancedSettings]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_arrayTime              : %1", TRGM_VAR_arrayTime]] remoteExec ["diag_log", 0];
[format ["[[TRGM - DEBUG]] TRGM_VAR_IsFullMap              : %1", TRGM_VAR_IsFullMap]] remoteExec ["diag_log", 0];

true;