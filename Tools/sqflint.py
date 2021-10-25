import argparse
import os
import re
import sys

from sqf.parser import identify_token, parse_strings_and_comments, tokenize, parse_block, EndOfFile, _analyze_tokens, String, KEYWORDS
import sqf.analyzer
from sqf.exceptions import SQFParserError, SQFWarning

unique_strings = []


def parse(script):
    parsed_tokens = parse_strings_and_comments(tokenize(script))
    tokens = [identify_token(x) for x in parsed_tokens]
    strings = list(filter(lambda x:
                          isinstance(x, String) and
                          '_' not in x.value and
                          ':' not in x.value and
                          '\n' not in x.value,
                          parsed_tokens))
    if len(strings) > 0:
        for x in strings:
            if x.value not in unique_strings:
                unique_strings.append(x.value)

    result = parse_block(tokens + [EndOfFile()], _analyze_tokens)[0]

    result.set_position((1, 1))

    return result


def string_not_in_exclusions_list(string):
    if "(not private)" in string:
        return False
    if "_fnc_scriptName" in string or "_fnc_scriptNameParent" in string:
        return False
    if "<Variable(get)>" in string:
        return False
    if re.match(r'.+?Variable "_[^"]+" not used', string) is not None:
        return False
    return True


class Writer:
    def __init__(self):
        self.strings = []

    def write(self, message):
        self.strings.append(message)


def analyze(code, writer, exceptions_list):
    try:
        result = parse(code)
    except SQFParserError as e:
        if string_not_in_exclusions_list(e.message):
            writer.write('[%d,%d]:%s\n' %
                         (e.position[0], e.position[1] - 1, e.message))
            exceptions_list += [e]
        return

    exceptions = sqf.analyzer.analyze(result).exceptions
    for e in exceptions:
        if string_not_in_exclusions_list(e.message):
            writer.write('[%d,%d]:%s\n' %
                         (e.position[0], e.position[1] - 1, e.message))
            exceptions_list += [e]


def analyze_dir(directory, writer, exceptions_list, exclude):
    """
    Analyzes a directory recursively
    """
    for root, dirs, files in os.walk(directory):
        if any([re.match(re.escape(s), root) for s in exclude.copy()]):
            writer.write(root + ' EXCLUDED\n')
            continue
        files.sort()
        for file in files:
            if file.endswith(".sqf"):
                file_path = os.path.join(root, file)
                if any([re.match(re.escape(s), file_path) for s in exclude.copy()]):
                    writer.write(file_path + ' EXCLUDED\n')
                    continue

                writer_helper = Writer()

                with open(file_path) as f:
                    analyze(f.read(), writer_helper, exceptions_list)

                if writer_helper.strings:
                    writer.write(os.path.relpath(file_path, directory) + '\n')
                    for string in writer_helper.strings:
                        if string_not_in_exclusions_list(string):
                            writer.write('\t%s' % string)
    return writer


def readable_dir(prospective_dir):
    if not os.path.isdir(prospective_dir):
        raise Exception(
            "readable_dir:{0} is not a valid path".format(prospective_dir))
    if os.access(prospective_dir, os.R_OK):
        return prospective_dir
    else:
        raise Exception(
            "readable_dir:{0} is not a readable dir".format(prospective_dir))


def parse_args(args):
    parser = argparse.ArgumentParser(description="Static Analyzer of SQF code")
    parser.add_argument('file', nargs='?', type=argparse.FileType('r'), default=None,
                        help='The full path of the file to be analyzed')
    parser.add_argument('-d', '--directory', nargs='?', type=readable_dir, default=None,
                        help='The full path of the directory to recursively analyse sqf files on')
    parser.add_argument('-o', '--output', nargs='?', type=argparse.FileType('w'), default=None,
                        help='File path to redirect the output to (default to stdout)')
    parser.add_argument('-x', '--exclude', action='append', nargs='?',
                        help='Path that should be ignored (regex)', default=[])
    parser.add_argument('-e', '--exit', type=str, default='',
                        help='How the parser should exit. \'\': exit code 0;\n'
                             '\'e\': exit with code 1 when any error is found;\n'
                             '\'w\': exit with code 1 when any error or warning is found.')

    return parser.parse_args(args)


def entry_point(args):
    args = parse_args(args)

    if args.output is None:
        writer = sys.stdout
    else:
        writer = args.output

    exceptions_list = []

    if args.directory is None:
        args.directory = os.path.join(os.getcwd(), "../")
        if (os.path.exists("Tools")):
            args.directory = os.getcwd()

    if args.file is None and args.directory is None:
        code = sys.stdin.read()
        analyze(code, writer, exceptions_list)
    elif args.file is not None:
        code = args.file.read()
        args.file.close()
        analyze(code, writer, exceptions_list)
    else:
        directory = args.directory.rstrip('/')
        exclude = list(map(lambda x: x if x.startswith(
            '/') else os.path.join(directory, x), args.exclude))
        analyze_dir(directory, writer, exceptions_list, exclude)

    with open(f'{args.directory.rstrip("/")}\\sqflint.log', 'a') as log:
        for string in unique_strings:
            log.write(string)
            log.write('\n')
        log.close()

    if args.output is not None:
        writer.close()

    exit_code = 0
    if args.exit == 'e':
        errors = [e for e in exceptions_list if isinstance(e, SQFParserError)]
        exit_code = int(len(errors) != 0)
    elif args.exit == 'w':
        errors_and_warnings = [e for e in exceptions_list if isinstance(
            e, (SQFWarning, SQFParserError))]
        exit_code = int(len(errors_and_warnings) != 0)
    return int(exit_code)


def main():
    sys.exit(entry_point(sys.argv[1:]))


if __name__ == "__main__":
    main()
