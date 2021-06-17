params [["_object", objNull, [objNull]]];

[(getPos _object) select 0, (getPos _object) select 1, ((getPos _object) select 2) + (_object distance (getPos _object))];