// by ALIAS
if (!hasinterface) exitwith {};
if (!isnil {
    player getVariable "ck_ON"
}) exitwith {};
player setVariable ["ck_ON", true];

alias_snow = "land_HelipadEmpty_F" createvehiclelocal [0, 0, 0];
// alias_snow = "Sign_Sphere100cm_F" createvehiclelocal [0, 0, 0];

KK_fnc_inHouse =
{
    _house = lineIntersectsSurfaces [getPosWorld _this, getPosWorld _this vectorAdd [0, 0, 50], _this, objNull, true, 1, "GEOM", "NONE"];
    if (((_house select 0) select 3) isKindOf "house") exitwith {
        pos_p = "in_da_house";
        cladire = ((_house select 0) select 3); casa= typeOf ((_house select 0) select 3); raza_snow = sizeOf casa
    };
    if ((getPosASL player select 2 < 0)&&(getPosASL player select 2 > -3)) exitwith {
        pos_p = "under_water";
        alias_snow setPosASL [(getPosASL player) select 0, (getPosASL player) select 1, 1]
    };
    if (getPosASL player select 2 < -3) exitwith {
        pos_p = "deep_sea"
    };
    if ((player != vehicle player)&&(getPosASL player select 2 > 0)) exitwith {
        pos_p = "player_car";
        /*alias_snow attachto [player, [0, 0, 15]]*/
    };
    pos_p = "open";
};
while {!isNull player} do {
    while {al_snowstorm_om} do {
        player call KK_fnc_inHouse;
        /* player sideChat (format ["%1", pos_p]);*/ sleep 0.5
    };
    waitUntil {
        sleep 10;
        al_snowstorm_om
    }
};