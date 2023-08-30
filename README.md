# asciidemo-tools
a framework to simplify generation of asciinema-based demos

## Background
Our team had some tribal knowledge around the use of [asciinema](https://asciinema.org/) and [asciicast2gif](https://github.com/asciinema/asciicast2gif) to generate demo clips used to supplement repository README.md.  
This represents an effort to commoditize that pipeline to make it easier to use/share.  
asciicast2gif was retired and replaced with [agg](https://github.com/asciinema/agg), which seems to be generally available and installable without much in the way of dependencies.

## Current Design Assumptions

- asciinema is locally installed or otherwise can be invoked using the `asciinema` command and standard option passing (note that running this as a container has implications on what commands can be executed, for e.g. starting kind clusters).
- agg is locally installed or otherwise can be invoked using the `agg` command and standard option passing

## Usage
The functional entrypoint is [generate-gif.sh](https://github.com/grokspawn/asciidemo-tools/blob/main/generate-gif.sh).  This script takes two (mandatory) positional parameters corresponding to the input script name and the output GIF filename. 

### input script requirements
Any input script can either function as a standlone script to be executed & captured, or can leverage a common library of convenience routines in [demo-functions.sh](https://github.com/grokspawn/asciidemo-tools/blob/main/demo-functions.sh).  To use the library routines, the input script should source the demo-functions.sh file.

#### Example:
[The following script](https://github.com/grokspawn/asciidemo-tools/blob/main/example/demo-script-major.sh)
1. identifies its home path and sources the function library it knows resides in the directory above it
2. performs some global actions to pre-configure the execution environment
3. executes a user-defined `run` function which exercises the library's `typeline` function to type (and optionally execute) the specified command

```bash
#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" > /dev/null 2>&1 ; pwd -P )"

#echo "SCRIPTPATH is $SCRIPTPATH"
. ../$SCRIPTPATH/demo-functions.sh

#echo "INTERACTIVE is $INTERACTIVE"

INFILE=$HOME/devel/example-operator-index/semver-veneer.yaml

sed -i -e 's/^generatemajorchannels: .$/generatemajorchannels: true/' $INFILE
sed -i -e 's/^generateminorchannels: .$/generateminorchannels: false/' $INFILE

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
```
execution of this script via a local git clone of this project might look like:
```bash
 % ~/devel/asciidemo-tools/generate-gif.sh ~/devel/asciidemo-tools/example/demo-script-major.sh ~/devel/asciidemo-tools/major-test.gif
```
(NB:  the example script in this case has some dependencies on the path to the `opm` binary, so has to be invoked from the where that path exists -- in this case, a clone of operator-registry)
