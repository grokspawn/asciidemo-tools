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

if [ $# -lt 2 ] 
then
    echo "ERROR: missing mandatory parameters: {INPUT_SCRIPT_FILE} and {OUTPUT_GIF_FILE}"
    usage
    exit -1
fi

INFILE=$1
OUTFILE=$2
shift 2

TMPFILE=$(mktemp $TMPDIR/asciinema.json.XXXXX)
if [ ! -e $TMPFILE ] 
then
    echo "ERROR:  failure to create tempfile"
    exit 1
fi

echo "tempfile: $TMPFILE"
echo "generating GIF $OUTFILE from script $INFILE"

# separate TMPFILE into its path/file components, since we'll need the path for volume mapping 
# and the file for the relative pathing inside that container
OUTER_PATH=$(dirname $TMPFILE)
JSON_FILE=$(basename $TMPFILE)
GIF_FILE=$(basename $OUTFILE)

TOGIF="docker run --rm -v $OUTER_PATH:/data asciinema/asciicast2gif"

INTERACTIVE=0 asciinema rec -i 2.5 --overwrite -c $INFILE $TMPFILE
$TOGIF -h 50 $JSON_FILE $GIF_FILE && rm $TMPFILE && mv $OUTER_PATH/$GIF_FILE $OUTFILE
