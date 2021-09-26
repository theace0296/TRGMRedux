// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getLocationName";
params[
    "_position",
    ["_useAtLocation",false],
    ["_distanceConsideredInArea",400]
];

if (isNil "_location") exitWith { ""; };

private _location = (nearestLocations [ _position, [ "NameVillage", "NameCity","NameCityCapital","NameMarine","Hill"],5000,_position]) select 0;
private _locationName =  text (_location);
private _locationPosition = position _location;

private _text = "";
if (_position distance2D _locationPosition > _distanceConsideredInArea) then {
    private _relDir = _locationPosition getDir _position;
    _text = format [localize "STR_TRGM2_location_fngetLocationName_DirOfName",[_relDir,true] call TRGM_GLOBAL_fnc_directionToText,_locationName];
} else {
    private _format =  ["%1",localize "STR_TRGM2_location_fngetLocationName_At"] select _useAtLocation;
    _text = format [_format,_locationName];
};
_text;