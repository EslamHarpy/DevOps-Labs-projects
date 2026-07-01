#!/bin/bash
USERNAME=$(whiptail --inputbox "Enter username to unlock/enable:" 8 45 3>&1 1>&2 2>&3)
if [ ! -z "$USERNAME" ]; then
    sudo usermod -U "$USERNAME" && whiptail --msgbox "User $USERNAME has been enabled!" 8 45
fi
