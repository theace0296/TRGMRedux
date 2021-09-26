// private _fnc_scriptName = "TRGM_GLOBAL_fnc_animateAnimals";



TRGM_LOCAL_fnc_animateWildLife = {
    sleep 10;
    params ["_pos"];
    {
       _x playMove "Dog_Sit";
    } forEach nearestObjects [_pos, ["Fin_random_F"], 2500];
    sleep 1;
    {
       _x playMove "Goat_Walk";
    }
    forEach nearestObjects [_pos, ["Goat_random_F"], 2500];
    sleep 1;
    {
       _x playMove "Dog_Idle_Stop";
    } forEach nearestObjects [_pos, ["Fin_random_F"], 2500];
    sleep 1;
    {
       _x playMove "Goat_Idle_Stop";
    } forEach nearestObjects [_pos, ["Goat_random_F"], 2500];

};

{
    [_x] spawn TRGM_LOCAL_fnc_animateWildLife;
} forEach TRGM_VAR_ObjectivePositions;


true;