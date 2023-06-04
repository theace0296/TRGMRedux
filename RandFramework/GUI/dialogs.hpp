
#include "defines.hpp"
#define UI_GRID_X    (safezoneX)
#define UI_GRID_Y    (safezoneY)
#define UI_GRID_W    (safezoneW / 40)
#define UI_GRID_H    (safezoneH / 25)
#define UI_GRID_WABS (safezoneW)
#define UI_GRID_HABS (safezoneH)

#define PADDING_W (UI_GRID_W * (2 / 3))
#define PADDING_H (1.5 * UI_GRID_H)

#define MISSION_TYPE_X (11.5 * UI_GRID_W + UI_GRID_X)
#define MISSION_TYPE_Y (7.28 * UI_GRID_H + UI_GRID_Y)
#define MISSION_TYPE_W (5 * UI_GRID_W)
#define MISSION_TYPE_H (1 * UI_GRID_H)

#define SLIDERTIMEX (15.46 * UI_GRID_W + UI_GRID_X)
#define SLIDERTIMEY (16.07 * UI_GRID_H + UI_GRID_Y)
#define SLIDERTIMEW (6.18854 * UI_GRID_W)
#define SLIDERTIMEH (0.54988 * UI_GRID_H)

#define ONETHIRDSLIDERTIMEW SLIDERTIMEW / 3
#define TWOTHIRDSLIDERTIMEW ONETHIRDSLIDERTIMEW * 2

#define TRGM_ORANGE    {0.85,0.45,0,1}
#define TRGM_BLUE      {0,0.45,0.85,1}
#define TRGM_BLACK     {0,0,0,1}
#define TRGM_WHITE     {1,1,1,1}
#define TRGM_INVISIBLE {0,0,0,0}

#define OBJECTIVE_Y (MISSION_TYPE_Y + PADDING_H)
#define OBJECTIVE_W (3 * UI_GRID_W)
#define OBJECTIVE_H (0.6 * UI_GRID_H)

#define OBJECTIVE_GROUP(INDEX) class ObjectiveGroup_##INDEX##: RscControlsGroupNoScrollbars\
{\
    idc = (5510 + INDEX);\
    x = (10 * UI_GRID_W + UI_GRID_X);\
    y = (OBJECTIVE_Y + (INDEX * OBJECTIVE_H));\
    w = (7 * OBJECTIVE_W);\
    h = OBJECTIVE_H;\
    onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";\
    class controls\
    {\
        class RscText_5200: RscText\
        {\
            idc = 5200;\
            text = __EVAL(format [localize "STR_TRGM2_dialogs_ObjectiveIndex", INDEX + 1]);\
            x = 1.10 * UI_GRID_W;\
            y = 0;\
            w = OBJECTIVE_W;\
            h = OBJECTIVE_H;\
            colorText[] = TRGM_ORANGE;\
        };\
        class RscCombo_5201: RscCombo\
        {\
            idc = 5201;\
            text = $STR_TRGM2_dialogs_Objective;\
            x = 3.00 * UI_GRID_W;\
            y = 0;\
            w = (2 * OBJECTIVE_W);\
            h = OBJECTIVE_H;\
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";\
            onLBSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";\
        };\
        class RscTextCheckbox_5202: RscTextCheckBox\
        {\
            idc = 5202;\
            x = 9.25 * UI_GRID_W;\
            y = 0;\
            w = OBJECTIVE_W;\
            h = OBJECTIVE_H;\
            strings[] = {$STR_TRGM2_dialogs_IsHeavy_False};\
            checked_strings[] = {$STR_TRGM2_dialogs_IsHeavy_True};\
            tooltips[] = {$STR_TRGM2_dialogs_IsHeavy_Tooltip};\
            values[] = {1};\
            colorText[] = TRGM_ORANGE;\
            colorBackground[] = TRGM_BLACK;\
            colorTextSelect[] = TRGM_BLUE;\
            colorSelectedBg[] = TRGM_BLACK;\
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";\
            onCheckBoxesSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";\
        };\
        class RscTextCheckbox_5203: RscTextCheckBox\
        {\
            idc = 5203;\
            x = 12.50 * UI_GRID_W;\
            y = 0;\
            w = OBJECTIVE_W;\
            h = OBJECTIVE_H;\
            strings[] = {$STR_TRGM2_dialogs_IsHidden_False};\
            checked_strings[] = {$STR_TRGM2_dialogs_IsHidden_True};\
            tooltips[] = {$STR_TRGM2_dialogs_IsHidden_Tooltip};\
            values[] = {1};\
            colorText[] = TRGM_ORANGE;\
            colorBackground[] = TRGM_BLACK;\
            colorTextSelect[] = TRGM_BLUE;\
            colorSelectedBg[] = TRGM_BLACK;\
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";\
            onCheckBoxesSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";\
        };\
        class RscTextCheckbox_5204: RscTextCheckBox\
        {\
            idc = 5204;\
            x = 15.75 * UI_GRID_W;\
            y = 0;\
            w = OBJECTIVE_W;\
            h = OBJECTIVE_H;\
            strings[] = {$STR_TRGM2_dialogs_IsSameAO_False};\
            checked_strings[] = {$STR_TRGM2_dialogs_IsSameAO_True};\
            tooltips[] = {$STR_TRGM2_dialogs_IsSameAO_Tooltip};\
            values[] = {1};\
            colorText[] = TRGM_ORANGE;\
            colorBackground[] = TRGM_BLACK;\
            colorTextSelect[] = TRGM_BLUE;\
            colorSelectedBg[] = TRGM_BLACK;\
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";\
            onCheckBoxesSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";\
        };\
    };\
}


class TRGM_VAR_DialogSetupParams
{
    idd = 5000;
    movingEnabled = false;

    class controlsBackground {
        class RscText_1200: RscText
        {
            idc = 5002;

            x = 11.01664 * UI_GRID_W + UI_GRID_X;
            y = 4.325525 * UI_GRID_H + UI_GRID_Y;
            w = 18.14852 * UI_GRID_W;
            h = 16.227975 * UI_GRID_H;
            colorBackground[] = {0.35,0.31,0.30,1};
            text = "";
        };
        class RscPicture_1200: RscPicture
        {
            idc = 5001;

            text = "RandFramework\Media\TRGMReduxLogo.paa";
            x = 16.90648 * UI_GRID_W + UI_GRID_X;
            y = 3.423325 * UI_GRID_H + UI_GRID_Y;
            w = 5.56832 * UI_GRID_W;
            h = 4.9509 * UI_GRID_H;
        };
    };

    class controls {
        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT START (by TheAce0296, v1.063, #Fiholy)
        ////////////////////////////////////////////////////////

        class RscTextCheckbox_5501: RscTextCheckBox
        {
            idc = 5501;

            x = MISSION_TYPE_X;
            y = MISSION_TYPE_Y;
            w = MISSION_TYPE_W;
            h = MISSION_TYPE_H;
            strings[] = {$STR_TRGM2_dialogs_IsCampaign_False};
            checked_strings[] = {$STR_TRGM2_dialogs_IsCampaign_True};
            tooltips[] = {$STR_TRGM2_dialogs_IsCampaign_Tooltip};
            values[] = {1};
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";
            onCheckBoxesSelChanged = "_this spawn TRGM_GUI_fnc_missionTypeSelection; false;";

            colorText[] = TRGM_ORANGE;
            colorBackground[] = TRGM_BLACK;
            colorTextSelect[] = TRGM_BLUE;
            colorSelectedBg[] = TRGM_BLACK;
        };
        class RscButton_5502: RscButton
        {
            idc = 5502;
            action = "[] spawn TRGM_GUI_fnc_addObjective;";

            text = $STR_TRGM2_dialogs_AddObjective;
            x = (MISSION_TYPE_X + MISSION_TYPE_W + PADDING_W);
            y = MISSION_TYPE_Y;
            w = (MISSION_TYPE_W * (2 / 3));
            h = MISSION_TYPE_H;
            colorBackground[] = TRGM_ORANGE;
            colorActive[] = TRGM_ORANGE;
        };
        class RscButton_5503: RscButton
        {
            idc = 5503;
            action = "[] spawn TRGM_GUI_fnc_removeObjective;";

            text = $STR_TRGM2_dialogs_RemoveObjective;
            x = (MISSION_TYPE_X + MISSION_TYPE_W + (2 * PADDING_W) + (MISSION_TYPE_W * (2 / 3)));
            y = MISSION_TYPE_Y;
            w = (MISSION_TYPE_W * (2 / 3));
            h = MISSION_TYPE_H;
            colorBackground[] = TRGM_ORANGE;
            colorActive[] = TRGM_ORANGE;
        };
        class RscTextCheckBox_5504: RscTextCheckBox
        {
            idc = 5504;

            x = (MISSION_TYPE_X + MISSION_TYPE_W + (3 * PADDING_W) + (2 * (MISSION_TYPE_W * (2 / 3))));
            y = MISSION_TYPE_Y;
            w = (MISSION_TYPE_W * (2 / 3));
            h = MISSION_TYPE_H;
            strings[] = {$STR_TRGM2_dialogs_IsFullMap_False};
            checked_strings[] = {$STR_TRGM2_dialogs_IsFullMap_True};
            tooltips[] = {$STR_TRGM2_dialogs_IsFullMap_Tooltip};
            values[] = {1};
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";
            onCheckBoxesSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";

            colorText[] = TRGM_ORANGE;
            colorBackground[] = TRGM_BLACK;
            colorTextSelect[] = TRGM_BLUE;
            colorSelectedBg[] = TRGM_BLACK;
        };

        OBJECTIVE_GROUP(7);
        OBJECTIVE_GROUP(6);
        OBJECTIVE_GROUP(5);
        OBJECTIVE_GROUP(4);
        OBJECTIVE_GROUP(3);
        OBJECTIVE_GROUP(2);
        OBJECTIVE_GROUP(1);
        OBJECTIVE_GROUP(0);

        class RscCombo_2100: RscCombo
        {
            idc = 5100;

            text = $STR_TRGM2_dialogs_HardcoreReputation;
            x = 15.46 * UI_GRID_W + UI_GRID_X;
            y = 14.42 * UI_GRID_H + UI_GRID_Y;
            w = 6.18854 * UI_GRID_W;
            h = 0.54988 * UI_GRID_H;
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";
            onLBSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";
        };
        class RscText_1004: RscText
        {
            idc = 5004;

            text = $STR_TRGM2_dialogs_HardcoreReputation;
            x = 11.96 * UI_GRID_W + UI_GRID_X;
            y = 14.42 * UI_GRID_H + UI_GRID_Y;
            w = 3.29958 * UI_GRID_W;
            h = 0.549984 * UI_GRID_H;
            colorText[] = TRGM_ORANGE;
        };
        class RscText_1005: RscText
        {
            idc = 5005;

            text = $STR_TRGM2_dialogs_Weather;
            x = 11.96 * UI_GRID_W + UI_GRID_X;
            y = 15.25 * UI_GRID_H + UI_GRID_Y;
            w = 3.29958 * UI_GRID_W;
            h = 0.549984 * UI_GRID_H;
            colorText[] = TRGM_ORANGE;
        };
        class RscCombo_2101: RscCombo
        {
            idc = 5101;

            text = $STR_TRGM2_dialogs_Weather;
            x = 15.46 * UI_GRID_W + UI_GRID_X;
            y = 15.25 * UI_GRID_H + UI_GRID_Y;
            w = 6.18854 * UI_GRID_W;
            h = 0.54988 * UI_GRID_H;
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";
            onLBSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";
        };
        class RscText_1014: RscText
        {
            idc = 5014;

            text = $STR_TRGM2_dialogs_Time;
            x = 11.96 * UI_GRID_W + UI_GRID_X;
            y = 16.07 * UI_GRID_H + UI_GRID_Y;
            w = 3.29958 * UI_GRID_W;
            h = 0.549984 * UI_GRID_H;
            colorText[] = TRGM_ORANGE;
        };
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // Time Slider
        ////////////////////////////////////////////////////////////////////////////////////////////////
        class PreviewNight1_2114: ctrlStaticPicture
        {
            idc = -1;
            text = "\a3\3DEN\Data\Attributes\SliderTimeDay\night_ca.paa";
            colorText[] = {1,1,1,0.60000002};
            x = SLIDERTIMEX + ONETHIRDSLIDERTIMEW - (SLIDERTIMEH / 2) + SLIDERTIMEH + SLIDERTIMEH - (3 * SLIDERTIMEH / 16);
            y = SLIDERTIMEY;
            w = SLIDERTIMEH;
            h = SLIDERTIMEH;
        };
        class PreviewNight2: ctrlStaticPicture
        {
            idc = -1;
            text = "\a3\3DEN\Data\Attributes\SliderTimeDay\night_ca.paa";
            colorText[] = {1,1,1,0.60000002};
            x = SLIDERTIMEX + ONETHIRDSLIDERTIMEW - (SLIDERTIMEH / 2) - SLIDERTIMEH - SLIDERTIMEH + (3 * SLIDERTIMEH / 16);
            y = SLIDERTIMEY;
            w = SLIDERTIMEH;
            h = SLIDERTIMEH;
        };
        class PreviewDay: ctrlStaticPicture
        {
            idc = -1;
            text = "\a3\3DEN\Data\Attributes\SliderTimeDay\day_ca.paa";
            colorText[] = {1,1,1,0.60000002};
            x = SLIDERTIMEX + ONETHIRDSLIDERTIMEW - (SLIDERTIMEH / 2);
            y = SLIDERTIMEY;
            w = SLIDERTIMEH;
            h = SLIDERTIMEH;
        };
        class PreviewSunrise: ctrlStaticPicture
        {
            idc = -1;
            text = "\a3\3DEN\Data\Attributes\SliderTimeDay\sunrise_ca.paa";
            colorText[] = {1,1,1,0.60000002};
            x = SLIDERTIMEX + ONETHIRDSLIDERTIMEW - (SLIDERTIMEH / 2) - SLIDERTIMEH;
            y = SLIDERTIMEY;
            w = SLIDERTIMEH;
            h = SLIDERTIMEH;
        };
        class PreviewSunset: ctrlStaticPicture
        {
            idc = -1;
            text = "\a3\3DEN\Data\Attributes\SliderTimeDay\sunset_ca.paa";
            colorText[] = {1,1,1,0.60000002};
            x = SLIDERTIMEX + ONETHIRDSLIDERTIMEW - (SLIDERTIMEH / 2) + SLIDERTIMEH;
            y = SLIDERTIMEY;
            w = SLIDERTIMEH;
            h = SLIDERTIMEH;
        };
        class Sun_2114: ctrlStaticPicture
        {
            idc = -1;
            text = "\a3\3DEN\Data\Attributes\SliderTimeDay\sun_ca.paa";
            colorText[] = {1,1,1,0.60000002};
            x = SLIDERTIMEX + ONETHIRDSLIDERTIMEW - (SLIDERTIMEH / 2);
            y = SLIDERTIMEY;
            w = SLIDERTIMEH;
            h = SLIDERTIMEH;
        };
        class Value_2114: RscXSliderH
        {
            idc = 5115;
            sliderRange[] = {0,23.9999};
            sliderPosition = 12;
            lineSize = 1;
            pageSize = 3600;
            border = "\a3\3DEN\Data\Attributes\SliderTimeDay\border_ca.paa";
            thumb = "\a3\3DEN\Data\Attributes\SliderTimeDay\thumb_ca.paa";
            color[] = {1,1,1,0.6};

            x = SLIDERTIMEX;
            y = SLIDERTIMEY;
            w = TWOTHIRDSLIDERTIMEW;
            h = SLIDERTIMEH;
            colorActive[] = TRGM_WHITE;

            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";
            onSliderPosChanged="[_this select 0, _this select 1, ""Slider""] call TRGM_GUI_fnc_timeSliderOnChange; _this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";
        };
        class Frame_2114: ctrlStaticFrame
        {
            idc = -1;
            x = SLIDERTIMEX + TWOTHIRDSLIDERTIMEW;
            y = SLIDERTIMEY;
            w = ONETHIRDSLIDERTIMEW;
            h = SLIDERTIMEH;
            colorText[] = TRGM_WHITE;
            colorBackground[] = TRGM_INVISIBLE;
            sizeEx = GUI_TEXT_SIZE_MEDIUM;
        };
        class Hour_2114: ctrlEdit
        {
            idc = 5116;
            text = "00";
            style = "0x02 + 0x200";
            x = SLIDERTIMEX + TWOTHIRDSLIDERTIMEW;
            y = SLIDERTIMEY;
            w = ONETHIRDSLIDERTIMEW / 3;
            h = SLIDERTIMEH;
            colorText[] = TRGM_WHITE;
            colorBackground[] = TRGM_INVISIBLE;
            tooltip = $STR_3DEN_Attributes_SliderTime_Hour_tooltip;
            sizeEx = GUI_TEXT_SIZE_MEDIUM;
            font = "EtelkaMonospacePro";
            onKillFocus = "[_this, nil, ""Edit""] call TRGM_GUI_fnc_timeSliderOnChange; false;";
        };
        class Minute_2114: Hour_2114
        {
            idc = 5117;
            text = "00";
            x = SLIDERTIMEX + TWOTHIRDSLIDERTIMEW + (ONETHIRDSLIDERTIMEW / 3);
            y = SLIDERTIMEY;
            w = ONETHIRDSLIDERTIMEW / 3;
            h = SLIDERTIMEH;
            colorText[] = TRGM_WHITE;
            colorBackground[] = TRGM_INVISIBLE;
            tooltip = $STR_3DEN_Attributes_SliderTime_Minute_tooltip;
            sizeEx = GUI_TEXT_SIZE_MEDIUM;
        };
        class Second_2114: Minute_2114
        {
            idc = 5118;
            text = "00";
            x = SLIDERTIMEX + TWOTHIRDSLIDERTIMEW + (ONETHIRDSLIDERTIMEW / 3) * 2;
            y = SLIDERTIMEY;
            w = ONETHIRDSLIDERTIMEW / 3;
            h = SLIDERTIMEH;
            colorText[] = TRGM_WHITE;
            colorBackground[] = TRGM_INVISIBLE;
            tooltip = $STR_3DEN_Attributes_SliderTime_Second_tooltip;
            sizeEx = GUI_TEXT_SIZE_MEDIUM;
        };
        class Separator_2114: ctrlStatic
        {
            idc = -1;
            text = "  :  :  ";
            style = 2;
            x = SLIDERTIMEX + TWOTHIRDSLIDERTIMEW;
            y = SLIDERTIMEY;
            w = ONETHIRDSLIDERTIMEW;
            h = SLIDERTIMEH;
            colorText[] = TRGM_WHITE;
            colorBackground[] = {0,0,0,0.5};
            sizeEx = GUI_TEXT_SIZE_MEDIUM;
            font="EtelkaMonospacePro";
        };
        ////////////////////////////////////////////////////////////////////////////////////////////////
        class RscText_1006: RscText
        {
            idc = 5006;

            text = $STR_TRGM2_dialogs_NVG;
            x = 11.96 * UI_GRID_W + UI_GRID_X;
            y = 16.9 * UI_GRID_H + UI_GRID_Y;
            w = 3.29958 * UI_GRID_W;
            h = 0.549984 * UI_GRID_H;
            colorText[] = TRGM_ORANGE;
        };
        class RscCombo_2102: RscCombo
        {
            idc = 5102;

            text = $STR_TRGM2_dialogs_NVG;
            x = 15.46 * UI_GRID_W + UI_GRID_X;
            y = 16.9 * UI_GRID_H + UI_GRID_Y;
            w = 6.18854 * UI_GRID_W;
            h = 0.54988 * UI_GRID_H;
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";
            onLBSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";
        };
        class RscText_1007: RscText
        {
            idc = 5007;

            text = $STR_TRGM2_dialogs_Revive;
            x = 11.96 * UI_GRID_W + UI_GRID_X;
            y = 17.72 * UI_GRID_H + UI_GRID_Y;
            w = 3.29958 * UI_GRID_W;
            h = 0.549984 * UI_GRID_H;
            colorText[] = TRGM_ORANGE;
        };
        class RscCombo_2103: RscCombo
        {
            idc = 5103;

            text = $STR_TRGM2_dialogs_Revive;
            x = 15.46 * UI_GRID_W + UI_GRID_X;
            y = 17.72 * UI_GRID_H + UI_GRID_Y;
            w = 6.18854 * UI_GRID_W;
            h = 0.54988 * UI_GRID_H;
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";
            onLBSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";
        };
        class RscText_1012: RscText
        {
            idc = 1012;

            text = $STR_TRGM2_dialogs_StartLocation;
            x = 11.96 * UI_GRID_W + UI_GRID_X;
            y = 18.55 * UI_GRID_H + UI_GRID_Y;
            w = 3.29958 * UI_GRID_W;
            h = 0.549984 * UI_GRID_H;
            colorText[] = TRGM_ORANGE;
        };
        class RscCombo_5104: RscCombo
        {
            idc = 5104;

            text = $STR_TRGM2_dialogs_StartLocation;
            x = 15.46 * UI_GRID_W + UI_GRID_X;
            y = 18.55 * UI_GRID_H + UI_GRID_Y;
            w = 6.18854 * UI_GRID_W;
            h = 0.54988 * UI_GRID_H;
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";
            onLBSelChanged = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnChange; false;";
        };
        class RscButton_1600: RscButton
        {
            idc = 5600;
            action = "[_this] spawn TRGM_GUI_fnc_setParamsAndBegin; false";

            text = $STR_TRGM2_dialogs_Begin;
            x = 23.3 * UI_GRID_W + UI_GRID_X;
            y = 16.07 * UI_GRID_H + UI_GRID_Y;
            w = 4.12568 * UI_GRID_W;
            h = 2.36963 * UI_GRID_H;
            colorBackground[] = TRGM_ORANGE;
            colorActive[] = TRGM_ORANGE;
        };
        class btnAdvanced: RscButton
        {
            idc = 1603;
            action = "[] spawn TRGM_GUI_fnc_openDialogAdvancedMissionSettings; false";

            text = $STR_TRGM2_dialogs_AdvOpt;
            x = 23.3 * UI_GRID_W + UI_GRID_X;
            y = 18.6 * UI_GRID_H + UI_GRID_Y;
            w = 4.12568 * UI_GRID_W;
            h = 0.550001 * UI_GRID_H;
            colorBackground[] = TRGM_ORANGE;
            colorActive[] = TRGM_ORANGE;
        };
        class RscText_1003: RscText
        {
            idc = 5003;

            x = 21.65 * UI_GRID_W + UI_GRID_X;
            y = 13.6 * UI_GRID_H + UI_GRID_Y;
            w = 0.619002 * UI_GRID_W;
            h = 0.550001 * UI_GRID_H;
        };
        class RscText_1008: RscText
        {
            idc = 5008;

            text = "[?]";
            x = 21.65 * UI_GRID_W + UI_GRID_X;
            y = 14.42 * UI_GRID_H + UI_GRID_Y;
            w = 0.619002 * UI_GRID_W;
            h = 0.550001 * UI_GRID_H;
            tooltip = $STR_TRGM2_dialogs_HardcoreReputation_HelpText;
        };
        class RscText_1009: RscText
        {
            idc = 5009;

            x = 21.65 * UI_GRID_W + UI_GRID_X;
            y = 15.25 * UI_GRID_H + UI_GRID_Y;
            w = 0.619002 * UI_GRID_W;
            h = 0.550001 * UI_GRID_H;
        };
        class RscText_1010: RscText
        {
            idc = 5010;

            x = 21.65 * UI_GRID_W + UI_GRID_X;
            y = 16.9 * UI_GRID_H + UI_GRID_Y;
            w = 0.619002 * UI_GRID_W;
            h = 0.550001 * UI_GRID_H;
        };
        class RscText_1011: RscText
        {
            idc = 5011;

            x = 21.65 * UI_GRID_W + UI_GRID_X;
            y = 17.72 * UI_GRID_H + UI_GRID_Y;
            w = 0.619002 * UI_GRID_W;
            h = 0.550001 * UI_GRID_H;
        };
        class RscText_1013: RscText
        {
            idc = 1013;

            text = "[?]";
            x = 21.65 * UI_GRID_W + UI_GRID_X;
            y = 18.55 * UI_GRID_H + UI_GRID_Y;
            w = 0.619002 * UI_GRID_W;
            h = 0.550001 * UI_GRID_H;
            tooltip = $STR_TRGM2_dialogs_StartLocation_HelpText;
        };
        class btnLoadLocalSave: RscButton
        {
            idc = 1601;
            action = "[_this,1] spawn TRGM_GUI_fnc_setParamsAndBegin; false";

            text = $STR_TRGM2_dialogs_LoadLocal;
            x = 23.3 * UI_GRID_W + UI_GRID_X;
            y = 14.42 * UI_GRID_H + UI_GRID_Y;
            w = 4.12502 * UI_GRID_W;
            h = 0.550001 * UI_GRID_H;
            colorBackground[] = TRGM_ORANGE;
            colorActive[] = TRGM_ORANGE;
            tooltip = $STR_TRGM2_dialogs_LoadLocal_HelpText;
        };
        class btnLoadglobalSave: RscButton
        {
            idc = 1602;
            action = "[_this,2] spawn TRGM_GUI_fnc_setParamsAndBegin; false";

            text = $STR_TRGM2_dialogs_LoadGlobal;
            x = 23.3 * UI_GRID_W + UI_GRID_X;
            y = 15.25 * UI_GRID_H + UI_GRID_Y;
            w = 4.12502 * UI_GRID_W;
            h = 0.550001 * UI_GRID_H;
            colorBackground[] = TRGM_ORANGE;
            colorActive[] = TRGM_ORANGE;
            tooltip = $STR_TRGM2_dialogs_LoadGlobal_HelpText;
        };
        class creditsText: RscStructuredText
        {
            idc = 7003;

            text = "<t color='#ccaaaa'>Visit <a href='https://github.com/theace0296/TRGMRedux'>TRGMRedux GitHub</a> for help and features...</t>";
            x = 15.67 * UI_GRID_W + UI_GRID_X;
            y = 19.65 * UI_GRID_H + UI_GRID_Y;
            w = 9.07386 * UI_GRID_W;
            h = 0.549984 * UI_GRID_H;
            colorText[] = {1,1,0,1};
        };

        class RscText_5500: RscText
        {
            idc = 5500;
            onLoad = "_this spawn TRGM_GUI_fnc_missionSetupControlsOnLoad; false;";

            x = 12.73232 * UI_GRID_W + UI_GRID_X;
            y = 19.32675 * UI_GRID_H + UI_GRID_Y;
            w = 14 * UI_GRID_W;
            h = 1.1 * UI_GRID_H;
            colorBackground[] = TRGM_BLACK;
            colorText[] = TRGM_WHITE;
            text = $STR_TRGM2_SetParamsAndBegin_ErrorMsg_NoData;
        };

        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT END
        ////////////////////////////////////////////////////////
    };
};


class TRGM_VAR_DialogSetupParamsAdvanced
    {
    idd = 6000;
    movingEnabled = false;

    class controls {

        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT START (by treendy, v1.063, #Nazety)
        ////////////////////////////////////////////////////////

        class RscPicture_6901: RscPicture
        {
            idc = 6901;
            text = "RandFramework\Media\table1.paa";
            x = 0.226718 * safezoneW + safezoneX;
            y = 0.0446 * safezoneH + safezoneY;
            w = 0.531094 * safezoneW;
            h = 0.935 * safezoneH;
        };

        //class RscText_6933: RscText
        //{
        //    idc = 6933;
        //    text = "Advanced Options";
        //    x = 0.298 * safezoneW + safezoneX;
        //    y = 0.236 * safezoneH + safezoneY;
        //    w = 0.175341 * safezoneW;
        //    h = 0.0659856 * safezoneH;
        //    colorText[] = {0,1,0,1};
        //};


        class btnAdvanced: RscButton
        {
            idc = 6903;
            text = $STR_TRGM2_dialogs_Back;
            x = 0.608281 * safezoneW + safezoneX;
            y = 0.7442 * safezoneH + safezoneY;
            w = 0.0773437 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,1,0,1};
            colorActive[] = {0,1,0,1};
            action = "[] spawn TRGM_GUI_fnc_openDialogMissionSelection; false";
        };

        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT END
        ////////////////////////////////////////////////////////

    };
};


class TRGM_VAR_DialogObjectiveManager
{
    idd = 9000;
    movingEnabled = false;
    class controls {};
};


class TRGM_VAR_DialogRequests
{
    idd = 8000;
    movingEnabled = false;

    class controls
    {
        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT START (by TheAce0296, v1.063, #Nosuty)
        ////////////////////////////////////////////////////////

        class RscPicture_8001: RscPicture
        {
            idc = 8001;
            text = "RandFramework\Media\table1.paa";
            x = 0.298932 * safezoneW + safezoneX;
            y = 0.236008 * safezoneH + safezoneY;
            w = 0.402137 * safezoneW;
            h = 0.527985 * safezoneH;
        };
        class RscButton_8003: RscButton
        {
            idc = 8003;
            text = $STR_TRGM2_openDialogRequests_RequestUnit;
            x = 0.365954 * safezoneW + safezoneX;
            y = 0.533006 * safezoneH + safezoneY;
            w = 0.123734 * safezoneW;
            h = 0.0549984 * safezoneH;
            colorBackground[] = {0,1,0,1};
            colorActive[] = {0,1,0,1};
        };
        class RscButton_8005: RscButton
        {
            idc = 8005;
            text = $STR_TRGM2_openDialogRequests_RequestVehicle;
            x = 0.520622 * safezoneW + safezoneX;
            y = 0.533006 * safezoneH + safezoneY;
            w = 0.123734 * safezoneW;
            h = 0.0549984 * safezoneH;
            colorBackground[] = {0,1,0,1};
            colorActive[] = {0,1,0,1};
        };

        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT END
        ////////////////////////////////////////////////////////

    };
};


class TRGM_VAR_DialogRequests_VehicleCustomization
{
    idd = 8080;
    enableSimulation = 1;

    icon = "\A3\Ui_f\data\Logos\a_64_ca.paa";
    logo = "\A3\Ui_f\data\Logos\arsenal_1024_ca.paa";
    class ControlsBackground
    {
        class BlackLeft: RscText
        {
            colorBackground[] = TRGM_BLACK;
            x = "safezoneXAbs";
            y = "safezoneY";
            w = "safezoneXAbs - safezoneX";
            h = "safezoneH";
        };
        class BlackRight: BlackLeft
        {
            x = "safezoneX + safezoneW";
        };
        class MouseArea: RscText
        {
            idc = 899;
            style = 16;
            x = "safezoneX";
            y = "safezoneY";
            w = "safezoneW";
            h = "safezoneH";
        };
    };
    class Controls
    {
        class ArrowLeft: RscButton
        {
            idc = 992;
            text = "-";
            x = -1;
            y = -1;
            w = "(((safezoneW / safezoneH) min 1.2) / 40)";
            h = "((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
        };
        class BackgroundLeft: RscText
        {
            fade = 1;
            idc = 994;
            x = "safezoneX + (1 + 1.5 * 2) * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY + 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            w = "15 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "safezoneH - 2.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            colorBackground[] = {0,0,0,0.5};
        };
        class LineIcon: RscFrame
        {
            fade = 1;
            idc = 1803;
            x = -1;
            y = -1;
            w = 0;
            h = 0;
            colorText[] = TRGM_BLACK;
        };
        class LineTabLeft: RscText
        {
            fade = 1;
            idc = 1804;
            x = -1;
            y = -1;
            w = "0.6 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "1.4 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            colorBackground[] = TRGM_BLACK;
        };
        class LineTabLeftSelected: RscText
        {
            idc = 1805;
            x = "safezoneX";
            y = -1;
            w = "0.5 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "1.4 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            colorBackground[] = {0,0,0,0.8};
        };
        class Tabs: RscFrame
        {
            fade = 1;
            idc = 1800;
            x = "safezoneX + 0.5 * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY + 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            w = "1.5 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "40 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            colorText[] = TRGM_INVISIBLE;
        };
        class FrameLeft: RscFrame
        {
            fade = 1;
            idc = 1801;
            x = "safezoneX + (1 + 1.5 * 2) * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY + 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            w = "15 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "safezoneH - 2.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            colorText[] = TRGM_BLACK;
        };
        class Message: RscText
        {
            fade = 1;
            idc = 996;
            x = "safezoneX + (0.5 * safezoneW) - (0.5 * ((safezoneW - 36 * (((safezoneW / safezoneH) min 1.2) / 40)) max 0.4))";
            y = "21.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + (safezoneY + safezoneH - (((safezoneW / safezoneH) min 1.2) / 1.2))";
            w = "((safezoneW - 36 * (((safezoneW / safezoneH) min 1.2) / 40)) max 0.4)";
            h = "1.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            colorBackground[] = {0,0,0,0.7};
            style = 2;
            shadow = 0;
            text = "";
            sizeEx = "0.8 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
        };
        class Space: RscControlsGroup
        {
            x = "safezoneX + safezoneW * 0.5 - 4 * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY";
            show = 0;
            idc = 27903;
            w = "8.1 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            class controls
            {
                class SpaceArsenalBackground: RscText
                {
                    idc = 26603;
                    x = "0 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    y = "0 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    w = "4 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    h = "2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    colorBackground[] = {0,0,0,0.7};
                };
                class SpaceArsenal: RscActivePicture
                {
                    idc = 26803;
                    text = "\a3\Ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa";
                    x = "1 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    y = "0 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    h = "2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    tooltip = "Arsenal";
                };
                class SpaceGarageBackground: SpaceArsenalBackground
                {
                    idc = 26604;
                    x = "4.1 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    y = "0 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    w = "4 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    h = "2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    colorBackground[] = {0,0,0,0.7};
                };
                class SpaceGarage: SpaceArsenal
                {
                    idc = 26804;
                    text = "\a3\Ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceGarage_ca.paa";
                    x = "5 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    y = "0 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    w = "1.99996 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    h = "2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    tooltip = "Garage";
                };
            };
        };
        class ControlBar: RscControlsGroupNoScrollbars
        {
            w = "safezoneW";
            idc = 44046;
            x = "0.5 * (((safezoneW / safezoneH) min 1.2) / 40) + (safezoneX)";
            y = "23.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + (safezoneY + safezoneH - (((safezoneW / safezoneH) min 1.2) / 1.2))";
            h = "1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            class controls
            {
                class ButtonClose: RscButtonMenu
                {
                    idc = 44448;
                    text = "Close";
                    x = "0 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    y = "0 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    w = "((safezoneW - 1 * (((safezoneW / safezoneH) min 1.2) / 40)) * 0.2) - 0.1 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    h = "1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                    tooltip = "Exit the Garage";
                };
                class ButtonInterface: ButtonClose
                {
                    idc = 44151;
                    text = "Hide";
                    x = "2 * ((safezoneW - 1 * (((safezoneW / safezoneH) min 1.2) / 40)) * 0.1)";
                    w = "((safezoneW - 1 * (((safezoneW / safezoneH) min 1.2) / 40)) * 0.1) - 0.1 * (((safezoneW / safezoneH) min 1.2) / 40)";
                    tooltip = "Hide the interface";
                };
                class ButtonOK: ButtonClose
                {
                    idc = 44346;
                    text = "OK";
                    x = "8 * ((safezoneW - 1 * (((safezoneW / safezoneH) min 1.2) / 40)) * 0.1)";
                    tooltip = "Use the selected loadout";
                };
            };
        };
        class MouseBlock: RscText
        {
            idc = 898;
            style = 16;
            x = "safezoneX";
            y = "safezoneY";
            w = "safezoneW";
            h = "safezoneH";
        };
        class MessageBox: RscMessageBox
        {
        };
        class TabAnimationSources: RscButtonArsenal
        {
            idc = "930 + 0";
            idcx = 930;
            text = "\A3\Ui_f\data\GUI\Rsc\RscDisplayGarage\AnimationSources_ca.paa";
            x = "safezoneX + 0.5 * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY + 0.5 * 0.04 + 0 * 0.04";
            w = "(1.4 * 2) * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "(1.4 * 2) * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            tooltip = "Components";
        };
        class ListAnimationSources: RscListBox
        {
            idc = "960 + 0";
            idcx = 960;
            x = "safezoneX + (1 + 1.5 * 2) * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY + 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            w = "15 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "safezoneH - 2.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            sizeEx = "1.4 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            colorBackground[] = TRGM_INVISIBLE;
            colorSelectBackground[] = {1,1,1,0.5};
            colorSelectBackground2[] = {1,1,1,0.5};
            colorPictureSelected[] = TRGM_WHITE;
            colorSelect[] = TRGM_WHITE;
            colorSelect2[] = TRGM_WHITE;
            colorPictureRightSelected[] = TRGM_WHITE;
        };
        class ListDisabledAnimationSources: RscText
        {
            idc = "860 + 0";
            x = "safezoneX + (1 + 1.5 * 2) * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY + 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            w = "15 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "safezoneH - 2.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            sizeEx = "2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            text = "N/A";
            style = 2;
            show = 0;
            colorText[] = {1,1,1,0.15};
            shadow = 0;
        };
        class TabTextureSources: RscButtonArsenal
        {
            idc = "930 + 1";
            idcx = 931;
            text = "\A3\Ui_f\data\GUI\Rsc\RscDisplayGarage\TextureSources_ca.paa";
            x = "safezoneX + 0.5 * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY + 0.5 * 0.04 + 3 * 0.04";
            w = "(1.4 * 2) * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "(1.4 * 2) * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            tooltip = "Camouflage";
        };
        class ListTextureSources: RscListBox
        {
            idc = "960 + 1";
            idcx = 961;
            x = "safezoneX + (1 + 1.5 * 2) * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY + 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            w = "15 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "safezoneH - 2.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            sizeEx = "1.4 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            colorBackground[] = TRGM_INVISIBLE;
            colorSelectBackground[] = {1,1,1,0.5};
            colorSelectBackground2[] = {1,1,1,0.5};
            colorPictureSelected[] = TRGM_WHITE;
            colorSelect[] = TRGM_WHITE;
            colorSelect2[] = TRGM_WHITE;
            colorPictureRightSelected[] = TRGM_WHITE;
        };
        class ListDisabledTextureSources: RscText
        {
            idc = "860 + 1";
            x = "safezoneX + (1 + 1.5 * 2) * (((safezoneW / safezoneH) min 1.2) / 40)";
            y = "safezoneY + 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            w = "15 * (((safezoneW / safezoneH) min 1.2) / 40)";
            h = "safezoneH - 2.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            sizeEx = "2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
            text = "N/A";
            style = 2;
            show = 0;
            colorText[] = {1,1,1,0.15};
            shadow = 0;
        };
    };
};


class KeypadDefuse
{
    idd = -1;
    movingEnable = 1;
    enableSimulation = 1;
    controlsBackground[] = {};
      objects[] = {};

    class controls
    {
        class B9: RscButton
        {
            idc = -1;
            x = 0.53197 * safezoneW + safezoneX;
            y = 0.5924 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 9]; ctrlSetText [1099, (ctrlText 1099) + str 9]";
        };
        class B8: RscButton
        {
            idc = -1;
            x = 0.504125 * safezoneW + safezoneX;
            y = 0.5924 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 8]; ctrlSetText [1099, (ctrlText 1099) + str 8]";
        };
        class B7: RscButton
        {
            idc = -1;
            x = 0.476148 * safezoneW + safezoneX;
            y = 0.592356 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 7]; ctrlSetText [1099, (ctrlText 1099) + str 7]";
        };
        class B6: RscButton
        {
            idc = -1;
            x = 0.532441 * safezoneW + safezoneX;
            y = 0.64143 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 6]; ctrlSetText [1099, (ctrlText 1099) + str 6]";
        };
        class B5: RscButton
        {
            idc = -1;
            x = 0.504273 * safezoneW + safezoneX;
            y = 0.643052 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 5]; ctrlSetText [1099, (ctrlText 1099) + str 5]";
        };
        class B4: RscButton
        {
            idc = -1;
            x = 0.47525 * safezoneW + safezoneX;
            y = 0.643 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 4]; ctrlSetText [1099, (ctrlText 1099) + str 4]";
        };
        class B3: RscButton
        {
            idc = -1;
            x = 0.531963 * safezoneW + safezoneX;
            y = 0.691778 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 3]; ctrlSetText [1099, (ctrlText 1099) + str 3]";
        };
        class B2: RscButton
        {
            idc = -1;
            x = 0.504752 * safezoneW + safezoneX;
            y = 0.692704 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 2]; ctrlSetText [1099, (ctrlText 1099) + str 2]";
        };
        class B1: RscButton
        {
            idc = -1;
            x = 0.476095 * safezoneW + safezoneX;
            y = 0.691778 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 1]; ctrlSetText [1099, (ctrlText 1099) + str 1]";
        };
        class B0: RscButton
        {
            idc = -1;
            x = 0.504124 * safezoneW + safezoneX;
            y = 0.742 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT set [count CODEINPUT, 0]; ctrlSetText [1099, (ctrlText 1099) + str 0]";
        };
        class Benter: RscButton
        {
            idc = -1;
            x = 0.532898 * safezoneW + safezoneX;
            y = 0.740504 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "[CODEINPUT] spawn TRGM_GUI_fnc_codeCompare; ";
        };
        class Bclear: RscButton
        {
            idc = -1;
            x = 0.477313 * safezoneW + safezoneX;
            y = 0.742 * safezoneH + safezoneY;
            w = 0.0165001 * safezoneW;
            h = 0.022 * safezoneH;
            colorFocused[] = {0.1,0.1,0.1,0.1};
            colorShadow[] = TRGM_INVISIBLE;
            colorBorder[] = {0.5,0.5,0.5,0};
            colorBackground[] = {0.7,0.7,0.7,0};
            colorBackgroundActive[] = {0.1,0.1,0.1,0};
            colorDisabled[] = {1,0,0,1};
            colorBackgroundDisabled[] = {0.5,0.5,0.5,0};
            borderSize = 0.015;
            offsetX = 0.005;
            offsetY = 0.005;
            offsetPressedX = 0.002;
            offsetPressedY = 0.002;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'button_click'; CODEINPUT = []; ctrlSetText [1099, str CODEINPUT]";
        };

        class KeypadImage: RscPicture
        {
            idc = -1;
            moving = 1;
            type = CT_STATIC;
            style = ST_PICTURE;
            x = 0.142156 * safezoneW + safezoneX;
            y = -0.1446 * safezoneH + safezoneY;
            w = 0.721875 * safezoneW;
            h = 1.254 * safezoneH;
            text = "RandFramework\Media\explosive.paa";
        };

        class Bblue: RscButton
        {
            idc = -1;
            x = 0.448438 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.020625 * safezoneW;
            h = 0.033 * safezoneH;
            colorBackground[] = {0,0,1,1};
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'wire_cut'; ['BLUE'] spawn TRGM_GUI_fnc_wireCompare";
        };
        class Bwhite: RscButton
        {
            idc = -1;
            x = 0.481437 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.020625 * safezoneW;
            h = 0.033 * safezoneH;
            colorBackground[] = TRGM_WHITE;
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'wire_cut'; ['WHITE'] spawn TRGM_GUI_fnc_wireCompare";
        };
        class Byellow: RscButton
        {
            idc = -1;
            x = 0.521656 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.020625 * safezoneW;
            h = 0.033 * safezoneH;
            colorBackground[] = {1,1,0,1};
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'wire_cut'; ['YELLOW'] spawn TRGM_GUI_fnc_wireCompare";
        };
        class Bgreen: RscButton
        {
            idc = -1;
            x = 0.558781 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.020625 * safezoneW;
            h = 0.033 * safezoneH;
            colorBackground[] = {0,1,0,1};
            soundClick[] = {"",0,0};
            onMouseButtonDown = "playSound 'wire_cut'; ['GREEN'] spawn TRGM_GUI_fnc_wireCompare";
        };
        class NumberDisplay: RscStructuredText
        {
            idc = 1099;
            type = CT_STATIC;
            style = ST_LEFT;
            colorText[] = {0.2,0.4,0,1};
            colorBackground[] = { 1, 1, 1, 0 };
            font = EtelkaNarrowMediumPro;
            sizeEx = 0.072;
            x = 0.474219 * safezoneW + safezoneX;
            y = 0.3258 * safezoneH + safezoneY;
            w = 0.136116 * safezoneW;
            h = 0.1418 * safezoneH;
        };
    };
};
