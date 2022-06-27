#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" > /dev/null 2>&1 ; pwd -P )"

#echo "SCRIPTPATH is $SCRIPTPATH"
. $SCRIPTPATH/../demo-functions.sh

#echo "INTERACTIVE is $INTERACTIVE"

INFILE=$HOME/devel/example-operator-index/semver-veneer.yaml

sed -i -e 's/^generatemajorchannels: .$/generatemajorchannels: false/' $INFILE
sed -i -e 's/^generateminorchannels: .$/generateminorchannels: true/' $INFILE

function run() {
	# pretty-print the input schema
	typeline -x "# <--> Pretty-print the input schema "
	typeline "yq $INFILE"
	typeline "clear"
	#clear
	typeline -x "# <--> Generate the rendered FBC with auto-generated channels"
	typeline "./bin/opm alpha render-veneer semver $INFILE -o yaml"
	#typeline './bin/opm alpha render-veneer semver' $INFILE '-o yaml | yq "select(.schema == \"olm.channel\")"'
	sleep 5
        typeline "clear"
	#clear
	typeline -x "# <--> Generate the mermaid graph data for auto-generated channels"
	typeline "./bin/opm alpha render-veneer semver $INFILE -o mermaid"
	sleep 10
	typeline -x "# <--> Done!"
}

run
