#!/usr/bin/env python3

import argparse
import enum
import json
import os
import subprocess
import sys
import time
import urllib.request

import xml.etree.ElementTree as ET


description = """
Notarizes a dmg file and staples the resulting notarization ticket to the file. The arguments are
passed to the xcrun altool utility, so more info can be obtained through 'xcrun altool --help'.

Requires Python 3.
"""

epilog = """
Note that if the password is provided through the keychain, you may be prompted to enter your login
password on every request to Apple's servers. A workaround is to pass the password in via something
like:
    --password `security find-generic-password -s <password-name> -w`
"""


# Time between calls to Apple's servers, polling for results of notarization.
POLL_WAIT_SECONDS = 30

# Max consecutive failures allowed.
POLL_MAX_RETRIES = 3

DEV_NULL = open(os.devnull, 'w')


class ParsingException(Exception):
    pass


class NotarizationResult(enum.Enum):
    in_progress = 1
    success = 2
    failure = 3


def print_stderr(*objects):
    print("%s:" % os.path.basename(__file__), *objects, file=sys.stderr)


def xml_dict_find(xml_dict, key):
    """ Returns the value associated with the given key in an XML dictionary structure. """

    if len(xml_dict) % 2 != 0:
        print(len(xml_dict))
        raise ParsingException("Expected dictionary to have an even number of elements (key, value pairs)")
    dict_iter = iter(xml_dict)
    for child in dict_iter:
        value = next(dict_iter)
        if child.text == key:
            return value
    return None


def get_error_message(upload_xml):
    """ Parses the error message out of the XML output from a notarization upload request. """

    try:
        root = ET.fromstring(upload_xml)
    except Exception as e:
        print(upload_xml, file=sys.stderr)
        raise ParsingException(e)
    d = root.find("dict")
    if d == None:
        raise ParsingException("Expected element 'dict' in root")
    errors = xml_dict_find(d, "product-errors")
    if errors == None:
        raise ParsingException("Expected key 'product-errors' in root.dict")
    errors_dict = errors.find("dict")
    if errors_dict == None:
        raise ParsingException("Expected element 'dict' in root.dict.product-errors")
    message = xml_dict_find(errors_dict, "message")
    if message == None:
        raise ParsingException("Expected key 'message' in root.dict.product-errors.dict")
    return message.text


def get_request_id(upload_xml):
    """ Parses the request ID out of the XML output from a notarization upload request. """

    try:
        root = ET.fromstring(upload_xml)
    except Exception as e:
        raise ParsingException(e)
    d = root.find("dict")
    if d == None:
        raise ParsingException("Expected element 'dict' in root")
    upload = xml_dict_find(d, "notarization-upload")
    if upload == None:
        raise ParsingException("Expected key 'notarization-upload' in root.dict")
    request_id = xml_dict_find(upload, "RequestUUID")
    if request_id == None:
        raise ParsingException("Expected key 'RequestUUID' in root.dict.notarization-upload")
    return request_id.text


def get_already_uploaded_request_id(upload_xml):
    """ Parses the request ID out of the XML output from a redundant upload request. """

    search_string = "The software asset has already been uploaded. The upload ID is "
    message = get_error_message(upload_xml)
    start = message.index(search_string) + len(search_string)
    end = start + message[start:].index("\"")
    return message[start:end]

def get_notarization_result(info_xml):
    """ Parses a notarization result out of the XML output from an info request. """
    try:
        root = ET.fromstring(info_xml)
    except Exception as e:
        raise ParsingException(e)
    d = root.find("dict")
    if d == None:
        raise ParsingException("Expected element 'dict' in root")
    notarization_info = xml_dict_find(d, "notarization-info")
    if notarization_info == None:
        raise ParsingException("Expected key 'notarization-info' in root.dict")
    status = xml_dict_find(notarization_info, "Status")
    if status == None:
        raise ParsingException("Expected key 'Status' in root.dict.notarization-info")
    if status.text == "success":
        return NotarizationResult.success
    if status.text == "in progress":
        return NotarizationResult.in_progress
    if status.text == "invalid":
        return NotarizationResult.failure
    raise ParsingException("Unexpected value for root.dict.notarization-info.Status: %s" % status.text)


def get_log_url(info_xml):
    """ Parses the log file URL out of the XML output from an info request. """
    try:
        root = ET.fromstring(info_xml)
    except Exception as e:
        raise ParsingException(e)
    d = root.find("dict")
    if d == None:
        raise ParsingException("Expected element 'dict' in root")
    notarization_info = xml_dict_find(d, "notarization-info")
    if notarization_info == None:
        raise ParsingException("Expected key 'notarization-info' in root.dict")
    log_url = xml_dict_find(notarization_info, "LogFileURL")
    if log_url == None:
        raise ParsingException("Expected key 'LogFileURL' in root.dict.notarization-info")
    return log_url.text


def retrieve_and_parse_log(info_xml):
    """ Retrieves the notarization log file and parses out any issues (including warnings). """
    log_url = get_log_url(info_stdout)
    log_json = urllib.request.urlopen(log_url).read()
    log = json.loads(log_json)
    try:
        return log['issues']
    except KeyError:
        raise ParsingException("Expected key 'issues' in log JSON")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("dmgfile")
    parser.add_argument("-b", "--primary-bundle-id", dest="bundle_id", required=True,
        help="Used to uniquely identify the package.")
    parser.add_argument("-u", "--username", dest="username", required=True,
        help="Apple ID used for the Apple Developer Program.")
    parser.add_argument("-p", "--password", dest="password", required=True,
        help="May be provided through keychain or env var; see 'xcrun altool --help'.")
    parser.add_argument("-a", "--asc-provider", dest="asc_provider", required=True,
        help="Used to determine which provider to associate the file with.")
    parser.add_argument("-t", "--max-wait-time", dest="max_wait_time", type=int, default=120,
        help="The maximum amount of time (in minutes) to wait for a notarization result.")
    args = parser.parse_args()

    validate_result = subprocess.call(
        ["xcrun", "stapler", "validate", args.dmgfile], stdout=DEV_NULL, stderr=DEV_NULL)
    if validate_result == 0:
        print_stderr("file already has notarization ticket attached - nothing to do")
        exit(0)

    print_stderr("uploading to notary servers...")
    upload_process = subprocess.Popen(["xcrun", "altool",
        "--notarize-app",
        "--username", args.username,
        "--password", args.password,
        "--primary-bundle-id", args.bundle_id,
        "--asc-provider", args.asc_provider,
        "--file", args.dmgfile,
        "--output-format", "xml"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    upload_result = upload_process.wait()
    upload_stdout = upload_process.stdout.read(-1).decode("utf-8")

    if upload_result == 0:
        print_stderr("upload complete")
        try:
            request_id = get_request_id(upload_stdout)
        except ParsingException as e:
            print(upload_stdout, file=sys.stderr)
            print_stderr("failed to parse output of upload process:", e)
            exit(1)
    else:
        if "already been uploaded" in get_error_message(upload_stdout):
            print_stderr("already uploaded")
            request_id = get_already_uploaded_request_id(upload_stdout)
        else:
            print(upload_stdout, file=sys.stderr)
            print_stderr("upload failed")
            exit(upload_result)

    print_stderr("polling servers for result (this may take some time)...")
    last_poll = time.time()
    poll_end = time.time() + args.max_wait_time * 60
    consecutive_retries = 0
    processing_complete = False
    while not processing_complete and time.time() < poll_end:
        info_process = subprocess.Popen(["xcrun", "altool",
            "--notarization-info", request_id,
            "--username", args.username,
            "--password", args.password,
            "--output-format", "xml"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        if info_process.wait() != 0:
            consecutive_retries += 1
            if consecutive_retries >= POLL_MAX_RETRIES:
                print(info_process.stdout.read(-1).decode("utf-8"), file=sys.stderr)
                print_stderr("%d consecutive failures polling for status; giving up" % POLL_MAX_RETRIES)
                exit(1)
            time.sleep(POLL_WAIT_SECONDS)
            continue
        consecutive_retries = 0
        info_stdout = info_process.stdout.read(-1).decode("utf-8")
        try:
            status = get_notarization_result(info_stdout)
            if status == NotarizationResult.success:
                print_stderr("notarization succeeded")
                processing_complete = True
            elif status == NotarizationResult.failure:
                print_stderr("notarization failed")
                try:
                    issues = retrieve_and_parse_log(info_stdout)
                    if len(issues) == 0:
                        print_stderr("found no issues in log file")
                        print_stderr("url:", get_log_url(info_stdout))
                        exit(1)
                    print_stderr("issues:")
                    for issue in issues:
                        print(issue, file=sys.stderr)
                except Exception as e:
                    print(info_stdout, file=sys.stderr)
                    print_stderr("failed to retrieve log file", e)
                    exit(1)
                exit(2)
            elif status == NotarizationResult.in_progress:
                time.sleep(POLL_WAIT_SECONDS)
        except ParsingException as e:
            print(info_stdout, file=sys.stderr)
            print_stderr("failed to parse output of info process:", e)
            exit(1)

    print_stderr("pulling log file...")
    try:
        issues = retrieve_and_parse_log(info_stdout)
        if len(issues) == 0:
            print_stderr("found no issues in log file")
            print_stderr("url:", get_log_url(info_stdout))
        else:
            print_stderr("found issues in log file:")
            for issue in issues:
                print(issue, file=sys.stderr)
    except Exception as e:
        print(info_stdout, file=sys.stderr)
        print_stderr("failed to retrieve log file", e)

    print_stderr("stapling notarization ticket to file")
    staple_result = subprocess.call(["xcrun", "stapler", "staple", args.dmgfile])
    if staple_result != 0:
        print_stderr("failed to staple notarization ticket")
        exit(1)
