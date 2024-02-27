#! /usr/bin/env sh

if [[ "$#" -ne 1 ]]; then
  echo "kaspersky.sh <LANTERN-VERSION>"
  exit 1
fi

set -e

URL=ftp://wl-GetLantern:EJaI3vVe9@whitelist1.kaspersky-labs.com
VERSION=$1
XML=lantern-$VERSION.xml
PATTERN=$XML*

out=$(echo ls $PATTERN | ftp $URL)
if [[ $out =~ $PATTERN.[[:digit:]]+.processed ]]; then
  echo "******$XML was processed by Kaspersky, force submitting"
elif [[ $out =~ $XML$ ]]; then
  echo "******$XML was submitted to Kaspersky, force submitting"
elif [[ -z $out ]]; then
  echo "Submitting $XML"
else
  echo "******WARNING: Abnormal state on Kaspersky FTP server, force submitting: \n$out"
fi

SCRIPT=$(greadlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
FULLXMLPATH=$SCRIPTPATH/$XML
sed s/"<VERSION>"/$VERSION/g $SCRIPTPATH/kaspersky.xml.tmpl > $FULLXMLPATH
ftp -u $URL/$XML $FULLXMLPATH
rm $FULLXMLPATH
exit $?
