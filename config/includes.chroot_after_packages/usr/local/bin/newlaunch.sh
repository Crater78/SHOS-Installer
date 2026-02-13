#!/usr/bin/env bash

GREEN_MARK="\e[32m✓\e[0m"
RED_X_MARK="\e[31m✗\e[0m"

gum_bubble() {
  gum style --foreground 33 --border-foreground 33 --border rounded --align
  center --width 25 --margin "1 2" --padding "1 4" '$1'
}

shutdown_system() {
    echo "Press enter to shut down:"
    input _
    systemctl poweroff
    exit 1
}

get_image() {
    HAOS_URL=$(curl -L -sS "https://crater78.github.io/SHOS-Installer/OS/build.txt")

    curl -L -o /tmp/home-assistant.img.xz "$HAOS_URL"
    local rc=$?
    
    return "$rc"
}

specs_check() {
    if [ ! -d /sys/firmware/efi ]; then
        return 2

    fi

    if [ $(uname -m) != "x86_64" ]; then
        return 3
    
    fi
    
    return 0
}

network_check() {
    NETWORK=1

    while [ "$NETWORK" -ne 0 ]; do
        echo "Checking Network Connection ..."
        
        getsomerest

        ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1

        NETWORK=$?

        return $NETWORK
    done
}

gum_bubble "Welcome to SHOS"

echo "Press enter to start the installer:"

input _

# System Specs Check

gum spin --title "Checking System Specs" -- specs_check

local rc=$?

case "$rc" in
    2)
      echo "Your system does not have UEFI enabled (or it is not supported), please enable it in BIOS, then try again"
      exit 1
      ;;
    3)
      echo "Your system is not supported, please use a x86 based system"
      exit 1
      ;;
    *)
      echo -e "${GREEN_MARK} System Specs Compatible"
      ;;
esac

# Network Check

NET=0

while [ net -ne 5 ]; do
    gum spin --title "Checking Network" -- network_check
    
    rc=$?
    
    case "$rc" in
        0)
         echo -e "${GREEN_MARK} Network Connected"
         NET=5
         ;;
        *)
         echo -e "${RED_X_MARK} No Network Connection"
         echo -e "On the next page, please pick a network to connect to"
         netui connect
    esac
    
    NET+=1
    
    if [ NET -eq 3 ]; then
        echo -e "${RED_X_MARK} Unable to connect"
        shutdown_system
    fi
done

# Image Fetch

gum spin --title "Geting HAOS" -- get_image

local rc=$?

if [ rc -ne 0 ]; then
     echo -e "${RED_X_MARK} Unable to download image"
     shutdown_system
fi

echo -e "${GREEN_MARK} Image Downloaded"


