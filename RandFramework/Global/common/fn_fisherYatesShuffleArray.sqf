// private _fnc_scriptName = "TRGM_GLOBAL_fnc_fisherYatesShuffleArray";

/******************************************************
This code is an implementation of the
Fisher-Yates Shuffle algorithm:
https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle.

The Fisher-Yates Shuffle is a technique for randomly
sorting the elements of an array. It works by iterating
through the array backwards, selecting a random element from
the remaining ones, and swapping it with the current one.
This process continues until all elements have been swapped.
******************************************************/

if !(_this isEqualtype []) exitwith {};
private ["_m", "_t", "_i"];
_this = +_this;
_m = count _this;
while {_m > 0} do {
    _i = floor (random 1 * _m);
    _m = _m - 1;
    _t = _this # _m;
    _this set [_m, _this # _i];
    _this set [_i, _t];
};
_this;