#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" > /dev/null 2>&1 ; pwd -P )"

set -o errexit
set -o pipefail

# todo: 
# - take script infile and gif outfile as parameters
# - determine directory of each and map the container volume path appropriately
# - if output dir is different than input dir, then mv to output dir (probably should use temp dir anyway)
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

# separate TMPFILE into its path/file components, since we'll need the path for volume mapping, and the file for the relative pathing inside that container
OUTER_PATH=$(dirname $TMPFILE)
JSON_FILE=$(basename $TMPFILE)
GIF_FILE=$(basename $OUTFILE)

TOGIF="docker run --rm -v $OUTER_PATH:/data asciinema/asciicast2gif"

INTERACTIVE=0 asciinema rec --overwrite -c $INFILE $TMPFILE
$TOGIF $JSON_FILE $GIF_FILE && rm $TMPFILE && mv $OUTER_PATH/$GIF_FILE $OUTFILE
#$TOGIF -w 102 -h 34 $JSON_FILE $GIF_FILE && rm $TMPFILE && mv $OUTER_PATH/$GIF_FILE $OUTFILE
