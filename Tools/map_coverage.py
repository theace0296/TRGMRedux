import os
import sys
import math


def get_formal_name_from_map_name(map_name):
    formal_names = {
        "altis": "Altis",
        "cam_lao_nam": "Cam Lao Nam",
        "chernarus": "Chernarus Autumn",
        "chernarus_summer": "Chernarus Summer",
        "chernarus_winter": "Chernarus Winter",
        "cup_chernarus_a3": "Chernarus 2020",
        "desert_island": "Desert Island",
        "enoch": "Livonia",
        "fallujah": "Fallujah",
        "intro": "Rahmadi",
        "kunduz": "Kunduz",
        "lythium": "Lythium, FFAA",
        "malden": "Malden 2035",
        "porto": "Porto",
        "prei_khmaoch_luong": "PKL (Legacy)",
        "rhspkl": "Prei Khmaoch Luong",
        "ruha": "Ruha",
        "sara": "Sahrani",
        "stratis": "Stratis",
        "takistan": "Takistan",
        "tanoa": "Tanoa",
        "tem_kujari": "Kujari",
        "utes": "Utes",
        "vt7": "Virolahti",
        "wake": "Wake",
        "woodland_acr": "Bystrica",
        "zargabad": "Zargabad",
        "abel": "Malden",
        "abramia": "Isla Abramia",
        "archipelago": "Archipelago",
        "australia": "Australia",
        "bootcamp_acr": "Bukovina",
        "cain": "Kolgujev",
        "chernarus_isles": "Chernarus Isles",
        "desert_e": "Desert",
        "dingor": "Dingor Island",
        "eden": "Everon",
        "gm_weferlingen_summer": "Weferlingen",
        "gm_weferlingen_winter": "Weferlingen W.",
        "isladuala3": "Isla Duala",
        "lingor3": "Lingor Island",
        "mountains_acr": "Takistan Mountains",
        "noe": "Nogova",
        "pabst_yellowstone": "Yellowstone",
        "panthera3": "Panthera",
        "pja310": "G.O.S Al Rayak",
        "provinggrounds_pmc": "Proving Grounds",
        "saralite": "Southern Sahrani",
        "sara_dbe1": "United Sahrani",
        "shapur_baf": "Shapur",
        "tembelan": "Tembelan Island",
        "winthera3": "Panthera (Winter)",
        "xcam_taunus": "X-Cam-Taunus",
        "stozec": "Gabreta",
    }
    if map_name in formal_names:
        return formal_names[map_name]
    return "UNKNOWN"


def format_name_for_table(name, max, filler=" "):
    if len(name) < max:
        diff = max - len(name)
        low = math.floor(diff / 2)
        high = math.ceil(diff / 2)
        return "{}{}{}".format(filler*low, name, filler*high)
    return name


def main():
    print("Checking map coverage")

    map_list = []
    filled_list = []
    empty_list = []
    bad_count = 0
    # Allow running from root directory as well as from inside the tools directory
    rootDir = "../Mission-Templates"
    if (os.path.exists("Tools")):
        rootDir = "./Mission-Templates"

    for dirname in os.listdir(rootDir + '/'):
        map_name = dirname.split(".").pop().casefold()
        map_name = f"{get_formal_name_from_map_name(map_name)} ({map_name})"
        if map_name not in map_list:
            map_list.append(map_name)
        if "empty" in dirname.casefold():
            empty_list.append(map_name)
        else:
            filled_list.append(map_name)

    print(
        "------\nChecked {0} files\nErrors detected: {1}".format(len(map_list), bad_count))

    map_list.sort()
    longest_name_length = 0
    for map_name in map_list:
        if len(map_name) > longest_name_length:
            longest_name_length = len(map_name)

    print("| {} | Filled | Empty |".format(
                format_name_for_table("Map", longest_name_length)))
    print("|-{}-|--------|-------|".format(
                format_name_for_table("-", longest_name_length, "-")))
    for map_name in map_list:
        if map_name not in filled_list:
            bad_count = bad_count + 1
            print("| {} |   ❌   |   ✔    |".format(
                format_name_for_table(map_name, longest_name_length)))
        elif map_name not in empty_list:
            bad_count = bad_count + 1
            print("| {} |   ✔    |   ❌   |".format(
                format_name_for_table(map_name, longest_name_length)))
        else:
            print("| {} |   ✔    |   ✔    |".format(
                format_name_for_table(map_name, longest_name_length)))

    if (bad_count == 0):
        print("Map coverage PASSED")
    else:
        print("Map coverage FAILED")

    return bad_count


if __name__ == "__main__":
    sys.exit(main())
