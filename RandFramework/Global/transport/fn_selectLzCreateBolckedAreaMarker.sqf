// private _fnc_scriptName = "TRGM_GLOBAL_fnc_selectLzCreateBolckedAreaMarker";
params ["_position","_radius",["_color","colorOPFOR"]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _uniqueMarkerName = format["redZone%1",str(_position)];
private _redZoneMarker = createMarkerLocal [_uniqueMarkerName, _position];
_redZoneMarker setMarkerShapeLocal "ELLIPSE";
_redZoneMarker setMarkerSizeLocal [_radius, _radius];
_redZoneMarker setMarkerColorLocal _color;
_redZoneMarker setMarkerAlphaLocal 0.5;
// return markerName
_redZoneMarker;