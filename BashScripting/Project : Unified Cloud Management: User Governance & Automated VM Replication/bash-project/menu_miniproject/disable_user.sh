#!/bin/bash
USERNAME=$(whiptail --inputbox "Enter username to lock/disable:" 8 45 3>&1 1>&2 2>&3)
if [ ! -z "$USERNAME" ]; then
    sudo usermod -L "$USERNAME" && whiptail --msgbox "User $USERNAME has been disabled!" 8 45
fi
