#!/bin/bash
USERNAME=$(whiptail --inputbox "Enter username to delete:" 8 45 3>&1 1>&2 2>&3)
if [ ! -z "$USERNAME" ]; then
    sudo userdel -r "$USERNAME" && whiptail --msgbox "User $USERNAME deleted!" 8 45
fi
