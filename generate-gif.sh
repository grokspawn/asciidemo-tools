#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" > /dev/null 2>&1 ; pwd -P )"
TMPDIR="${TMPDIR:-/tmp/}"
volume_name="image-tmp"

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

function cleanup() {
   exit_status=$?
   docker volume rm ${volume_name}
   docker rm loader
   exit $exit_Status
}
trap cleanup EXIT

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
chmod a+r $TMPFILE

echo "tempfile: $TMPFILE"
echo "generating GIF $OUTFILE from script $INFILE"

# separate TMPFILE into its path/file components, since we'll need the path for volume mapping 
# and the file for the relative pathing inside that container
OUTER_PATH=$(dirname $TMPFILE)
JSON_FILE=$(basename $TMPFILE)
GIF_FILE=$(basename $OUTFILE)

TOGIF="docker run --rm --name asciicast2gif -v ${volume_name}:/data asciinema/asciicast2gif"

INTERACTIVE=0 asciinema rec -i 2.5 --overwrite -c $INFILE $TMPFILE

docker volume create ${volume_name}
docker container create --name loader -v ${volume_name}:/data hello-world
docker cp $TMPFILE loader:/data/$JSON_FILE
docker rm loader

$TOGIF -h 50 /data/$JSON_FILE /data/$GIF_FILE

docker container create --name loader -v ${volume_name}:/data hello-world
docker cp loader:/data/$GIF_FILE $OUTFILE
docker rm loader
rm $TMPFILE
