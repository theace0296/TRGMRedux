params[
    "_position",
    ["_useAtLocation",false],
    ["_distanceConsideredInArea",400]
];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


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