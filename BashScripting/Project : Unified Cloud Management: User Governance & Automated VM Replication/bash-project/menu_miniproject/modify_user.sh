#!/bin/bash
USERNAME=$(whiptail --inputbox "Enter username to modify:" 8 45 3>&1 1>&2 2>&3)
if [ ! -z "$USERNAME" ]; then
    NEW_SHELL=$(whiptail --inputbox "Enter new shell (e.g., /bin/bash):" 8 45 3>&1 1>&2 2>&3)
    if [ ! -z "$NEW_SHELL" ]; then
        sudo usermod -s "$NEW_SHELL" "$USERNAME" && whiptail --msgbox "User $USERNAME modified successfully!" 8 45
    fi
fi
