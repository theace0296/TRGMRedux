params ["_veh"];

if (isNil "_veh") exitWith {};

_veh setVectorUp [0,0,1];
_veh setPosATL [(getPosATL _veh) select 0, (getPosATL _veh) select 1, 1];
true;