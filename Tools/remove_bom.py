import fnmatch
import os
import sys

if sys.version_info.major == 2:
    import codecs
    open = codecs.open


def main():
    print("Removing BOMs")

    file_list = []
    bad_count = 0
    # Allow running from root directory as well as from inside the tools directory
    rootDir = "../"
    if (os.path.exists("Tools")):
        rootDir = "."

    for root, dirnames, filenames in os.walk(rootDir + '/'):
        for filename in fnmatch.filter(filenames, '*.sqf'):
            file_list.append(os.path.join(root, filename))
        for filename in fnmatch.filter(filenames, '*.hpp'):
            file_list.append(os.path.join(root, filename))
        for filename in fnmatch.filter(filenames, '*.ext'):
            file_list.append(os.path.join(root, filename))
        for filename in fnmatch.filter(filenames, '*.xml'):
            file_list.append(os.path.join(root, filename))

    for filename in file_list:
        try:
            content = open(filename, mode='r', encoding='utf-8-sig').read()
            open(filename, mode='w', encoding='utf-8').write(content)
        except Exception:
            bad_count = bad_count + 1

    print(
        "------\nChecked {0} files\nErrors detected: {1}".format(len(file_list), bad_count))
    if (bad_count == 0):
        print("BOM validation PASSED")
    else:
        print("BOM validation FAILED")

    return bad_count


if __name__ == "__main__":
    sys.exit(main())
