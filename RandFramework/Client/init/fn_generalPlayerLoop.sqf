// private _fnc_scriptName = "TRGM_CLIENT_fnc_generalPlayerLoop";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


waitUntil {
    if (side player != civilian) then {
        if (count TRGM_VAR_ObjectivePositions > 0 && TRGM_VAR_AllowUAVLocateHelp) then {
            private _useAceInteractionForTransport = [false, true] select ((["EnableAceActions", 0] call BIS_fnc_getParamValue) isEqualTo 1);
            if ((player distance (TRGM_VAR_ObjectivePositions select 0)) < 25) then {
                if ((player getVariable ["calUAVActionID", -1]) isEqualTo -1) then {
                    [(localize "STR_TRGM2_TRGMInitPlayerLocal_UAVAvailable")] call TRGM_GLOBAL_fnc_notify;
                    if (_useAceInteractionForTransport && call TRGM_GLOBAL_fnc_isAceLoaded) then {
                        private _selfAction = [
                            'STR_TRGM2_TRGMInitPlayerLocal_CallUAV',
                            localize 'STR_TRGM2_TRGMInitPlayerLocal_CallUAV',
                            '',
                            {[0] spawn TRGM_GLOBAL_fnc_callUAVFindObjective}
                        ] call ACE_interact_menu_fnc_createAction;
                        [_selfAction] call TRGM_GLOBAL_fnc_addAceActionToPlayer;
                        player setVariable ["calUAVActionID", _selfAction];
                    } else {
                        private _actionID = player addAction [localize "STR_TRGM2_TRGMInitPlayerLocal_CallUAV",{[0] spawn TRGM_GLOBAL_fnc_callUAVFindObjective}];
                        player setVariable ["calUAVActionID",_actionID];
                    };
                };
            } else {
               if ((player getVariable ["calUAVActionID", -1]) != -1) then {
                   if (_useAceInteractionForTransport && call TRGM_GLOBAL_fnc_isAceLoaded) then {
                       [(player getVariable ["calUAVActionID", -1])] call TRGM_GLOBAL_fnc_removeAceActionFromPlayer;
                       player setVariable ["calUAVActionID", nil];
                   } else {
                       player removeAction (player getVariable ["calUAVActionID", -1]);
                       player setVariable ["calUAVActionID", nil];
                   };
                   [localize "STR_TRGM2_TRGMInitPlayerLocal_UAVNoAvailable"] call TRGM_GLOBAL_fnc_notify;
               };
            };
        };
        if (leader (group (vehicle player)) isEqualTo player && (call TRGM_GETTER_fnc_bSupportOption)) then {
            if (TRGM_VAR_iMissionIsCampaign) then {
                if (TRGM_VAR_CampaignInitiated) then {

                    private _dCurrentRep = [TRGM_VAR_MaxBadPoints - TRGM_VAR_BadPoints,1] call BIS_fnc_cutDecimals;
                    if (_dCurrentRep >= 1) then {
                        //["hmm2"] call TRGM_GLOBAL_fnc_notify;
                        [player, supReqSupply] call BIS_fnc_addSupportLink;
                        sleep 1;
                    };
                    if (_dCurrentRep >= 3) then {
                        //["hmm2"] call TRGM_GLOBAL_fnc_notify;
                        [player, supReq] call BIS_fnc_addSupportLink;
                        sleep 1;
                    };
                    if (_dCurrentRep >= 7) then {
                        //["hmm3"] call TRGM_GLOBAL_fnc_notify;
                        [player, supReqAir] call BIS_fnc_addSupportLink;
                        sleep 1;
                    };
                };
            } else {
                [player, supReqSupply] call BIS_fnc_addSupportLink;
                sleep 1;
                [player, supReq] call BIS_fnc_addSupportLink;
                sleep 1;
                [player, supReqAir] call BIS_fnc_addSupportLink;
                sleep 1;
            }
        };
    };
    sleep 10;
    false;
};