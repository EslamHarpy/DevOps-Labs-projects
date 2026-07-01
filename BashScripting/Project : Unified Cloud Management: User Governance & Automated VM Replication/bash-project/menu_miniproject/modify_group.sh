#!/bin/bash
GROUPNAME=$(whiptail --inputbox "Enter group name to modify:" 8 45 3>&1 1>&2 2>&3)
if [ ! -z "$GROUPNAME" ]; then
    USERNAME=$(whiptail --inputbox "Enter username to add to this group:" 8 45 3>&1 1>&2 2>&3)
    if [ ! -z "$USERNAME" ]; then
        sudo usermod -aG "$GROUPNAME" "$USERNAME" && whiptail --msgbox "User $USERNAME added to $GROUPNAME!" 8 45
    fi
fi
