#!/usr/bin/env bash

# A function that shows a error to the user
# ARGS: $1: MSG (STRING)
wt_error() {
    # Make sure the right number of args was entered
    if [ $# -ne 1 ]; then
        echo "Usage: wt_error BadArgs" >&2
        return 2
    fi

    # Show Whiptail Dialog
    whiptail --msgbox "$1" \
        --ok-button "Back" \
        --title "SHOS: ERROR" \
        --clear \
        0 0
    
    return 0
}

# A function that shows a msg to the user
# ARGS: $1: MSG (STRING) $2 BUTTON TEXT (STRING)
wt_msg() {
    # Make sure the right number of args was entered
    if [[ $# -ne 1 && $# -ne 2 ]]; then
        echo "Usage: wt_msg BadArgs" >&2
        return 2
    fi

    local button_text=${2:-"Continue"}
        
    # Show Whiptail Dialog
    whiptail --msgbox "$1" \
        --ok-button "$button_text" \
        --title "SHOS" \
        --clear \
        0 0
    
    return 0
}