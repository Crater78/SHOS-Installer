TERM=linux
#!/usr/bin/env bash
TITLE="SHOS"

echo "SHOS Ready ..."

getsomerest() {
    sleep 3
}

specs_check() {
    echo "Checking System Specs ..."

    getsomerest

    # TODO: Write Code to Check Specs

    SPECS=1

    if [ "$SPECS" -eq 0 ]; then
        whiptail --title "ERROR"\
        --msgbox "Your system does not meet the specifications required to install Home Assistant"\
        --ok-button "Main Menu"\
        --clear \
        0 0\

        mainloop
    fi
}

network_flow() {
    NETWORK=1

    while [ "$NETWORK" -ne 0 ]; do
        echo "Checking Network Connection ..."
        
        getsomerest

        ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1

        NETWORK=$?

        if [ "$NETWORK" -ne 0 ]; then
            echo "No Network Connection ..."
            getsomerest

            whiptail --title $TITLE\
                --msgbox "On the next page, please pick a network to connect to."\
                --ok-button "Continue"\
                --clear \
                0 0\
            
            nmtui connect
        fi
    done
}

get_image() {
    echo "Fetching HAOS Image ..."

    getsomerest

    curl -L -o /tmp/home-assistant.img.xz "https://github.com/home-assistant/operating-system/releases/download/17.0/haos_generic-x86-64-17.0.img.xz"
    
    getsomerest

    echo "Image Downloaded"
}

flash_image() {
    echo "Scanning Disks ..."
    
    local options=()

    echo "Scanning Disks ..."

    while read -r name type size model; do
        [ "$type" = "disk" ] || continue

        echo "$name"

        options+=("/dev/$name" "$size $model")
    done < <(lsblk -dn -o NAME,TYPE,SIZE,MODEL)

    echo "Loading disk options ..."

    TARGET_DISK=$(
        whiptail --title "$TITLE" \
                 --menu "Select target disk\nAll data on the selected disk will be ERASED:" \
                 --clear \
                 0 0 0 \
                 "${options[@]}" \
                 3>&1 1>&2 2>&3
    )

    echo "Starting Flash ..."

    xzcat /tmp/home-assistant.img.xz | dd of="$TARGET_DISK" bs=4M status=progress conv=fsync
    
    sync
}

reboot_system() {
    whiptail --title $TITLE\
                --msgbox "HAOS has been instaled, press enter to reboot, then remove the boot media"\
                --ok-button "Continue"\
                --clear \
                0 0\
    
    reboot
}

install_flow() {
    clear
    
    echo "Getting Ready to Install SHOS ..."

    # Check System Specs
    specs_check

    # Setup Network
    network_flow

    # Download Image
    get_image

    getsomerest

    # Flash Image to Disk
    flash_image

    getsomerest

    # Reboot
    reboot_system
}

about_flow() {
    whiptail --title $TITLE\
    --msgbox "SHOS is open-source software designed to install Home Assistant on x86 platforms.\nIt is released under the Apache 2.0 License, and developed by Crater78, with contributions from the community.\nVisit https://github.com/Crater78/SHOS-Installer to learn more!\nDisclaimer: SHOS is not related to or endorsed by the Home Assistant Team."\        0 0\
    --ok-button "Back"\
    --clear \
    0 0\

    mainloop
}

debug_mode_flow() {
    clear

    echo "Entering Debug Mode"
    
    exec /bin/bash
}

mainloop () {
    MENU=$(whiptail --title $TITLE\
        --menu "Main Menu"\
        --nocancel \
        --clear \
        0 0 0\
        "1" "Install Home Assistant"\
        "2" "About SHOS"\
        "3" "Exit SHOS"\
        "4" "Debug Mode"\
    3>&1 1>&2 2>&3)

    case "$MENU" in
        1)
            install_flow
            ;;
        2)
            about_flow
            ;;
        3)
            shutdown
            ;;
        4)  debug_mode_flow
            ;;
        *)
            shutdown
            ;;
    esac
}

clear

mainloop