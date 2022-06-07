#!/usr/bin/env bash

INTERACTIVE=${INTERACTIVE:-"1"}
NOEXEC=0

prompt() {
    echo ""
    echo -n "$ "
}

typeline() {
    case $1 in
       -x) 
           NOEXEC=1
           shift
           CMD=$*
           ;;
       *) 
	   NOEXEC=0
           CMD=$* 
           ;;
    esac

    prompt
    sleep 1
    for (( i=0; i<${#CMD}; i++ )); do
        echo -n "${CMD:$i:1}"
        sleep 0.06
    done
    echo ""
    sleep 0.25
    [[ "$NOEXEC" == "0" ]] && $CMD
    [[ "$INTERACTIVE" == "1" ]] && read -p "hit <ENTER> to continue..."
}
