#!/usr/bin/env bash
TITLE="SHOS"
TERM=linux

echo "SHOS Ready ..."

getsomerest() {
    sleep 3
}

specs_check() {
    echo "Checking System Specs ..."

    getsomerest

    if [ ! -d /sys/firmware/efi ]; then
        whiptail --title "ERROR"\
        --msgbox "Your system does not have UEFI enabled (or it is not supported), please enable it in BIOS, then try again"\
        --ok-button "Main Menu"\
        --clear \
        0 0\

        mainloop
        return

    fi

    if [ $(uname -m) != "x86_64" ]; then
        whiptail --title "ERROR"\
        --msgbox "Your system is not supported, please use a x86 based system"\
        --ok-button "Main Menu"\
        --clear \
        0 0\

        mainloop
        return
    
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

            whiptail --title "$TITLE"\
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

    HAOS_URL=$(curl -L -sS "https://crater78.github.io/SHOS-Installer/OS/build.txt")

    curl -L -o /tmp/home-assistant.img.xz "$HAOS_URL"
    
    getsomerest

    echo "Image Downloaded"
}

flash_image() {
    echo "Scanning Disks ..."
    
    DISK=1

    while [ "$DISK" -ne 0 ]; then
        clear

        local options=()

        echo "Scanning Disks ..."

        boot_disk=$(lsblk -no PKNAME "$(findmnt -no SOURCE /)" 2>/dev/null)

        while read -r name type size model; do
            [ "$type" = "disk" ] || continue

            [ "$name" != "$boot_disk" ] || continue

            echo "$name"

            options+=("/dev/$name" "$size $model")
        done < <(lsblk -dn -o NAME,TYPE,SIZE,MODEL | grep -P '\s([0-9]+T|[2-9][1-9]G|[3-9][0-9]G|[1-9][0-9][0-9]G)$')

        echo "Loading disk options ..."

        TARGET_DISK=$(
            whiptail --title "$TITLE" \
                    --menu "Select target disk\nAll data on the selected disk will be ERASED! (Disks under 20GB are not shown):"\
                    --clear \
                    --cancel-button "Main Menu" \
                    0 0 0 \
                    "${options[@]}" \
                    3>&1 1>&2 2>&3
        )

        EXITSTATUS=$?

        if [ "$EXITSTATUS" -ne 0 ]; then
            mainloop
            return
        fi

        DISK=0

        if [ -z "$TARGET_DISK" ]; then
            whiptail --title "ERROR"\
            --msgbox "Please select a disk"\
            --ok-button "Back"\
            --clear \
            0 0\

            DISK=1
            
        fi
    done

    whiptail --title "$TITLE"\
        --yesno "This will erase all data on $TARGET_DISK, are you sure you want to continue?"\
        --clear \
        0 0\

    if [ $? -ne 0 ]; then
        mainloop
        return
    fi

    echo "Starting Flash ..."

    xzcat /tmp/home-assistant.img.xz | dd of="$TARGET_DISK" bs=4M status=progress conv=fsync
    
    DD_STATUS=$?

    if [ "$DD_STATUS" -ne 0 ]; then
        whiptail --title "ERROR"\
        --msgbox "Flash failed, error code $DD_STATUS"\
        --ok-button "Main Menu"\
        --clear \
        0 0\

        mainloop
        return
    fi

    sync
}

reboot_system() {
    whiptail --title "$TITLE"\
                --msgbox "HAOS has been instaled, remove the boot media, then press enter to reboot"\
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
    whiptail --title "$TITLE"\
    --msgbox "SHOS is open-source software designed to install Home Assistant on x86 platforms.\nIt is released under the Apache 2.0 License, and developed by Crater78, with contributions from the community.\nVisit https://github.com/Crater78/SHOS-Installer to learn more!\nDisclaimer: SHOS is not related to or endorsed by the Home Assistant Team."\
    --ok-button "Back"\
    --clear \
    0 0\

    mainloop
    return
}

debug_mode_flow() {
    clear

    echo "Entering Debug Mode"
    
    exec /bin/bash
}

mainloop () {
    MENU=$(whiptail --title "$TITLE"\
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
            shutdown -h now
            ;;
        4)  debug_mode_flow
            ;;
        *)
            shutdown -h now
            ;;
    esac
}

clear

mainloop