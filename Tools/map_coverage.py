import os
import sys
import math


def format_name_for_table(name, max):
    if len(name) < max:
        diff = max - len(name)
        low = math.floor(diff / 2)
        high = math.ceil(diff / 2)
        return "{}{}{}".format(" "*low, name, " "*high)
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
        if map_name not in map_list:
            map_list.append(map_name)
        if "empty" in dirname.casefold():
            empty_list.append(map_name)
        else:
            filled_list.append(map_name)

    print(
        "------\nChecked {0} files\nErrors detected: {1}".format(len(map_list), bad_count))
    print("|          Map          | Filled | Empty |")
    print("|-----------------------|--------|-------|")
    for map_name in map_list:
        if map_name not in filled_list:
            bad_count = bad_count + 1
            print("| {} |   N    |   Y   |".format(format_name_for_table(map_name, 21)))
        elif map_name not in empty_list:
            bad_count = bad_count + 1
            print("| {} |   Y    |   N   |".format(format_name_for_table(map_name, 21)))
        else:
            print("| {} |   Y    |   Y   |".format(format_name_for_table(map_name, 21)))

    if (bad_count == 0):
        print("Map coverage PASSED")
    else:
        print("Map coverage FAILED")

    return bad_count


if __name__ == "__main__":
    sys.exit(main())
