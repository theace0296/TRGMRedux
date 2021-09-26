// private _fnc_scriptName = "TRGM_SERVER_fnc_setFireFightEvent";
params ["_posOfAO", "_eventType"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

//1=fullWar  2=AOOnly  3=WarzoneOnly 4=warzoneOnlyFullWar
if (!isServer || isNil "_posOfAO" || isNil "_eventType" || !(_eventType in [1, 2, 3, 4])) exitWith {};

call TRGM_SERVER_fnc_initMissionVars;

private _nearLocations = nearestLocations [_posOfAO, ["NameCity","NameCityCapital","NameVillage"], 1500];
private _eventLocationPos = nil;
if (!isNil("TRGM_VAR_ForceWarZoneLoc")) then {
    _eventLocationPos = _posOfAO;
} else {
    {
        private _xLocPos = locationPosition _x;
        if (_xLocPos distance _posOfAO > 950) then {
            _eventLocationPos = _xLocPos;
        };
    } forEach _nearLocations;


    if (isNil("_eventLocationPos")) then {
        private _buildings = nearestObjects [_posOfAO, TRGM_VAR_BasicBuildings, 2000];
        {
            private _xLocPos = position _x;
            private _bIsClearFromAOCamp = true;
            if (!isNil "TRGM_VAR_AOCampPos") then {
                if (_xLocPos distance TRGM_VAR_AOCampPos < 500) then {
                    _bIsClearFromAOCamp = false;
                };
            };
            if (_xLocPos distance _posOfAO > 950 && _bIsClearFromAOCamp) then {
                _eventLocationPos = _xLocPos;
            };
        } forEach _buildings;
    };
};

if (isNil("_eventLocationPos")) then {_eventType = 2};

TRGM_VAR_WarzonePos = _eventLocationPos;

if (_eventType isEqualTo 1 || _eventType isEqualTo 3 || _eventType isEqualTo 4) then {
    private _mrkEnemy = createMarker ["mrkWarzoneEnemy", _eventLocationPos];
    _mrkEnemy setMarkerText "!!WARNING!! KEEP CLEAR";
    _mrkEnemy setMarkerShape "ICON";
    _mrkEnemy setMarkerColor "ColorEAST";
    _mrkEnemy setMarkerType "mil_warning";

    private _mrkFriendlyPos = _eventLocationPos getPos [200 * sqrt random 1, random 360];
    private _mrkFriendly = createMarker ["mrkWarzoneFriendly", _mrkFriendlyPos];
    _mrkFriendly setMarkerShape "ICON";
    private _mrkFriendlyDir = [_mrkFriendlyPos, _eventLocationPos] call BIS_fnc_DirTo;
    _mrkFriendly setMarkerDir _mrkFriendlyDir;
    _mrkFriendly setMarkerColor "ColorWEST";
    _mrkFriendly setMarkerType "mil_arrow2";
};

private _objPos = _eventLocationPos getPos [100 * sqrt random 1, random 360];
if (random 1 < .50 || _eventType isEqualTo 1 || _eventType isEqualTo 4) then {
    private _flatPos1 =  _eventLocationPos getPos [100 * sqrt random 1, random 360];
    _flatPos1 = [_eventLocationPos , 0, 100, 8, 0, 0.5, 0,[],[_flatPos1,_flatPos1]] call TRGM_GLOBAL_fnc_findSafePos;
    tracer1 setPos _flatPos1;

    private _flatPos2 =  _eventLocationPos getPos [100 * sqrt random 1, random 360];
    _flatPos2 = [_eventLocationPos , 0, 100, 8, 0, 0.5, 0,[],[_flatPos2,_flatPos2]] call TRGM_GLOBAL_fnc_findSafePos;
    tracer2 setPos _flatPos2;

    private _flatPos3 =  _eventLocationPos getPos [100 * sqrt random 1, random 360];
    _flatPos3 = [_eventLocationPos , 0, 100, 8, 0, 0.5, 0,[],[_flatPos3,_flatPos3]] call TRGM_GLOBAL_fnc_findSafePos;
    tracer3 setPos _flatPos3;

    private _flatPos4 =  _eventLocationPos getPos [100 * sqrt random 1, random 360];
    _flatPos4 = [_eventLocationPos , 0, 100, 8, 0, 0.5, 0,[],[_flatPos4,_flatPos4]] call TRGM_GLOBAL_fnc_findSafePos;
    tracer4 setPos _flatPos4;
};

private _mainAOPos = TRGM_VAR_ObjectivePositions select 0;
TRGM_VAR_WarEventActive = true;

[_eventLocationPos] spawn {
    private _eventLocationPos = _this select 0;
    while {TRGM_VAR_WarEventActive} do {
        private _type = selectRandom ["Bomb_03_F","Missile_AA_04_F","M_Mo_82mm_AT_LG"];
        private _xPos = (_eventLocationPos select 0)-125;
        private _yPos = (_eventLocationPos select 1)-125;


        if (random 1 < .15) then {
            private _li_aaa = _type createVehicleLocal [_xPos+(random 250),_yPos+(random 250),0];
            _li_aaa setDamage 1;
        } else {
            private _group = createGroup TRGM_VAR_EnemySide;
            private _sUnitType = selectRandom [(call sRiflemanToUse),(call sMachineGunManToUse)];
            private _tempFireUnit = [_group, _sUnitType,[_xPos+(random 250),_yPos+(random 250),0],[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
            hideObject _tempFireUnit;
            sleep 1;
            private _shotsToFire = selectRandom[3,10,15];
            private _weapon = currentWeapon _tempFireUnit;
            private _ammo = _tempFireUnit ammo _weapon;
            private _sleep = selectRandom [0.05,0.1];
            while {_shotsToFire > 0} do {
                _tempFireUnit forceWeaponFire [_weapon, "FullAuto"];
                _shotsToFire = _shotsToFire - 1;
                sleep _sleep;
            };
            deleteVehicle _tempFireUnit;
        };
        private _sleep = 1 + (random 6);
        private _diceRoll = floor(random 12)+1;
        if (_diceRoll isEqualTo 1) then {_sleep = 10 + random 5};
        if (_diceRoll > 6) then {_sleep = 0.5 + random 1};
        sleep _sleep;
      };
};

[_eventLocationPos] spawn {
    private _eventLocationPos = _this select 0;

    while {TRGM_VAR_WarEventActive} do {
        waitUntil {sleep 10; TRGM_VAR_bAndSoItBegins && TRGM_VAR_CustomObjectsSet && TRGM_VAR_PlayersHaveLeftStartingArea};

        private _AirToUse = selectRandom (call FriendlyJet);
        private _NoOfVeh = selectRandom [1,2];
        private _bSetCaptive = random 1 < .75;
        if (random 1 < .33) then {
            _AirToUse = selectRandom (call FriendlyChopper);
        };
        private _pos = _eventLocationPos getPos [3000,random 360];//random 360 and 3 clicks out and no playable units within 2 clicks
        _pos = [_pos select 0,_pos select 1, 365];
        private _dir = [_pos, _eventLocationPos] call BIS_fnc_DirTo;//dir from pos to _eventLocationPos
        private _WarzoneGroupp1 = createGroup TRGM_VAR_FriendlySide;
        private _WarZoneAir1 = createVehicle [_AirToUse, _pos, [], 0, "FLY"];
        _WarZoneAir1 setDir _dir;
        [TRGM_VAR_FriendlySide, _WarZoneAir1, true] call TRGM_GLOBAL_fnc_createVehicleCrew;
        _WarZoneAir1 flyInHeight 45;
        _WarZoneAir1 setBehaviour "CARELESS";
        _WarZoneAir1 setSpeedMode "FULL";
        _WarZoneAir1 doMove (_pos getPos [60000,_dir]);
        _WarZoneAir1 setCaptive _bSetCaptive;
        private _WarZoneAir2 = nil;
        if (_NoOfVeh > 1) then {
            private _pos2 = _pos getPos [30,random 360];
            _WarZoneAir2 = createVehicle [_AirToUse, _pos2, [], 0, "FLY"];
            _WarZoneAir2 setDir _dir;
            [_WarzoneGroupp1, _WarZoneAir2] call TRGM_GLOBAL_fnc_createVehicleCrew;
            _WarZoneAir2 flyInHeight 45;
            _WarZoneAir2 setBehaviour "CARELESS";
            _WarZoneAir2 setSpeedMode "FULL";
            _WarZoneAir2 doMove (_pos getPos [60000,_dir]);
            _WarZoneAir2 setCaptive _bSetCaptive;
        };

        [_WarZoneAir1,_eventLocationPos] spawn {
            private _veh = _this select 0;
            private _eventLocationPos = _this select 1;
            while {alive _veh} do {
                private _curDist = _veh distance _eventLocationPos;
                if (_curDist > 4000) then {
                    {_veh deleteVehicleCrew _x} forEach crew _veh;
                    deleteVehicle _veh;
                };
            };
        };

        if (_NoOfVeh > 1) then {
            [_WarZoneAir2,_eventLocationPos] spawn {
                private _veh = _this select 0;
                private _eventLocationPos = _this select 1;
                while {alive _veh} do {
                    private _curDist = _veh distance _eventLocationPos;
                    if (_curDist > 4000) then {
                        {_veh deleteVehicleCrew _x} forEach crew _veh;
                        deleteVehicle _veh;
                    };
                };
            };
        };
        sleep selectRandom [240,480];
    };
};

true;