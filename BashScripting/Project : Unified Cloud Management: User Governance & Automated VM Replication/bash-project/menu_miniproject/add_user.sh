#!/bin/bash
USERNAME=$(whiptail --inputbox "Enter the new username:" 8 45 3>&1 1>&2 2>&3)
if [ ! -z "$USERNAME" ]; then
    sudo useradd "$USERNAME" && whiptail --msgbox "User $USERNAME added successfully!" 8 45
fi
