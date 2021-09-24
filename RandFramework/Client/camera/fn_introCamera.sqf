// private _fnc_scriptName = "TRGM_CLIENT_fnc_introCamera";
////INSTANT FADE TO BLACK SCREEN
cutText ["","BLACK FADED",1];

////CREATE CAMERA
private _cam = "camera" camCreate (getPosATL player);
_cam cameraEffect ["External","BACK"];

////WAIT FOR BRIEFING TO END
sleep 0.1;
doStop player;

////INITIATE ANIMATION OVER NETWORK
[player] remoteExec ["TRGM_CLIENT_fnc_startingMove", [0, -2] select isMultiplayer, true];

////WAIT A SECOND
sleep 1;

////DESTROY CAMERA
_cam cameraEffect ["Terminate", "BACK"];
_cam camCommit 0;
waitUntil { sleep 5; camCommitted _cam };
camDestroy _cam;

////FADE IN FROM BLACK SCREEN
cutText ["","BLACK IN",3];