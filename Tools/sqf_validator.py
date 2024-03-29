#!/usr/bin/env python

import fnmatch
import os
import sys
import re

if sys.version_info.major == 2:
    import codecs
    open = codecs.open


def getPublicVariables(content):
    pattern = re.compile(r"publicVariable [\"']([^\"']+)[\"']", re.I)
    matches = pattern.findall(content)
    if (matches is not None):
        return matches
    return []


def validKeyWordAfterCode(content, index):
    keyWords = ["for", "do", "count", "each", "forEach", "else", "and", "not",
                "isEqualTo", "in", "call", "spawn", "execVM", "catch", "param", "select", "apply"]
    for word in keyWords:
        try:
            subWord = content.index(word, index, index+len(word))
            return True
        except Exception:
            pass
    return False


def check_sqf_syntax(filepath, publicVariables):
    bad_count_file = 0

    with open(filepath, 'r', encoding='utf-8', errors='ignore') as file:
        content = file.read()
        for publicVariable in getPublicVariables(content):
            if (publicVariable not in publicVariables):
                publicVariables.append(publicVariable)

        # Store all brackets we find in this file, so we can validate everything on the end
        brackets_list = []

        # To check if we are in a comment block
        isInCommentBlock = False
        checkIfInComment = False
        # Used in case we are in a line comment (//)
        ignoreTillEndOfLine = False
        # Used in case we are in a comment block (/* */). This is true if we detect a * inside a comment block.
        # If the next character is a /, it means we end our comment block.
        checkIfNextIsClosingBlock = False

        # We ignore everything inside a string
        isInString = False
        # Used to store the starting type of a string, so we can match that to the end of a string
        inStringType = ''

        lastIsCurlyBrace = False
        checkForSemiColon = False
        onlyWhitespace = True

        # Extra information so we know what line we find errors at
        lineNumber = 1

        indexOfCharacter = 0
        # Parse all characters in the content of this file to search for potential errors
        for c in content:
            if (lastIsCurlyBrace):
                lastIsCurlyBrace = False
                checkForSemiColon = True

            if c == '\n':  # Keeping track of our line numbers
                onlyWhitespace = True  # reset so we can see if # is for a preprocessor command
                # so we can print accurate line number information when we detect a possible error
                lineNumber += 1
            if (isInString):  # while we are in a string, we can ignore everything else, except the end of the string
                if (c == inStringType):
                    isInString = False
            # if we are not in a comment block, we will check if we are at the start of one or count the () {} and []
            elif (isInCommentBlock is False):

                # This means we have encountered a /, so we are now checking if this is an inline comment or a comment block
                if (checkIfInComment):
                    checkIfInComment = False
                    if c == '*':  # if the next character after / is a *, we are at the start of a comment block
                        isInCommentBlock = True
                    elif (c == '/'):  # Otherwise, will check if we are in an line comment
                        # and an line comment is a / followed by another / (//) We won't care about anything that comes after it
                        ignoreTillEndOfLine = True

                if (isInCommentBlock is False):
                    # we are in a line comment, just continue going through the characters until we find an end of line
                    if (ignoreTillEndOfLine):
                        if (c == '\n'):
                            ignoreTillEndOfLine = False
                    else:  # validate brackets
                        if (c == '"' or c == "'"):
                            isInString = True
                            inStringType = c
                        elif (c == '#' and onlyWhitespace):
                            ignoreTillEndOfLine = True
                        elif (c == '/'):
                            checkIfInComment = True
                        elif (c == '('):
                            brackets_list.append('(')
                        elif (c == ')'):
                            if (brackets_list[-1] in ['{', '[']):
                                print("ERROR: Possible missing round bracket ')' detected at {0} Line number: {1}".format(
                                    filepath, lineNumber))
                                bad_count_file += 1
                            brackets_list.append(')')
                        elif (c == '['):
                            brackets_list.append('[')
                        elif (c == ']'):
                            if (brackets_list[-1] in ['{', '(']):
                                print("ERROR: Possible missing square bracket ']' detected at {0} Line number: {1}".format(
                                    filepath, lineNumber))
                                bad_count_file += 1
                            brackets_list.append(']')
                        elif (c == '{'):
                            brackets_list.append('{')
                        elif (c == '}'):
                            lastIsCurlyBrace = True
                            if (brackets_list[-1] in ['(', '[']):
                                print("ERROR: Possible missing curly brace '}}' detected at {0} Line number: {1}".format(
                                    filepath, lineNumber))
                                bad_count_file += 1
                            brackets_list.append('}')
                        elif (c == '\t'):
                            print("ERROR: Tab detected at {0} Line number: {1}".format(
                                filepath, lineNumber))
                            bad_count_file += 1

                        if (c not in [' ', '\t', '\n']):
                            onlyWhitespace = False

                        if (checkForSemiColon):
                            # keep reading until no white space or comments
                            if (c not in [' ', '\t', '\n', '/']):
                                checkForSemiColon = False
                                # , 'f', 'd', 'c', 'e', 'a', 'n', 'i']):
                                if (c not in [']', ')', '}', ';', ',', '&', '!', '|', '='] and
                                        not validKeyWordAfterCode(content, indexOfCharacter)):
                                    print("ERROR: Possible missing semicolon ';' detected at {0} Line number: {1}".format(
                                        filepath, lineNumber))
                                    bad_count_file += 1

            else:  # Look for the end of our comment block
                if (c == '*'):
                    checkIfNextIsClosingBlock = True
                elif (checkIfNextIsClosingBlock):
                    if (c == '/'):
                        isInCommentBlock = False
                    elif (c != '*'):
                        checkIfNextIsClosingBlock = False
            indexOfCharacter += 1

        if brackets_list.count('[') != brackets_list.count(']'):
            print("ERROR: A possible missing square bracket [ or ] in file {0} [ = {1} ] = {2}".format(
                filepath, brackets_list.count('['), brackets_list.count(']')))
            bad_count_file += 1
        if brackets_list.count('(') != brackets_list.count(')'):
            print("ERROR: A possible missing round bracket ( or ) in file {0} ( = {1} ) = {2}".format(
                filepath, brackets_list.count('('), brackets_list.count(')')))
            bad_count_file += 1
        if brackets_list.count('{') != brackets_list.count('}'):
            print("ERROR: A possible missing curly brace {{ or }} in file {0} {{ = {1} }} = {2}".format(
                filepath, brackets_list.count('{'), brackets_list.count('}')))
            bad_count_file += 1
    return bad_count_file


def main():

    print("Validating SQF")

    sqf_list = []
    bad_count = 0

    # Allow running from root directory as well as from inside the tools directory
    rootDir = "../"
    if (os.path.exists("Tools")):
        rootDir = "."

    for root, dirnames, filenames in os.walk(rootDir + '/'):
        for filename in fnmatch.filter(filenames, '*.sqf'):
            sqf_list.append(os.path.join(root, filename))

    publicVariables = []
    for filename in sqf_list:
        bad_count = bad_count + check_sqf_syntax(filename, publicVariables)
    print(
        "------\nChecked {0} files\nErrors detected: {1}".format(len(sqf_list), bad_count))
    if (bad_count == 0):
        print("SQF validation PASSED")
    else:
        print("SQF validation FAILED")

    print(f"Number of unique public variables: {len(publicVariables)}")

    return bad_count


if __name__ == "__main__":
    sys.exit(main())
