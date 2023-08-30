#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" > /dev/null 2>&1 ; pwd -P )"

set -o errexit
set -o pipefail

function usage() {
    echo << EOF
    usage: $0 {INPUT_SCRIPT_FILE} {OUTPUT_GIF_FILE}
    where
        INPUT_SCRIPT_FILE the shell script containing instructions to be executed and captured
        OUTPUT_GIF_FILE   the GIF capturing the demo recording after animation completes

    both are mandatory parameters
EOF
}

function check_prereq() {
   prog=$1
   echo -n "Checking prerequisite ($prog) ... "
   if command -v $prog &> /dev/null
   then
      echo "ok"
   else
	echo "ERROR"
	exit 1
   fi
}

if [ $# -lt 2 ] 
then
    echo "ERROR: missing mandatory parameters: {INPUT_SCRIPT_FILE} and {OUTPUT_GIF_FILE}"
    usage
    exit -1
fi

INFILE=$1
OUTFILE=$2
shift 2

PREREQUISITES="asciinema agg"
for req in $PREREQUISITES
do
   check_prereq $req
done

: "${TMPDIR:=/tmp/}"
# normalize tmpdir path, because sometimes it has a trailing '/' char and this
# can result in a doubling of that char, which some parsers don't like
NORMALIZED_TMPDIR=$(realpath $TMPDIR)
TMPFILE=$(mktemp $NORMALIZED_TMPDIR/asciinema.json.XXXXX)
if [ ! -e $TMPFILE ] 
then
    echo "ERROR:  failure to create tempfile"
    exit 1
fi

echo "tempfile: $TMPFILE"
echo "generating GIF $OUTFILE from script $INFILE"

INTERACTIVE=0 asciinema rec -i 2.5 --overwrite -c $INFILE $TMPFILE
agg --last-frame-duration 10 $TMPFILE $OUTFILE && rm $TMPFILE
