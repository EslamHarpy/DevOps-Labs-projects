#!/bin/bash
USERNAME=$(whiptail --inputbox "Enter username to change password:" 8 45 3>&1 1>&2 2>&3)
if [ ! -z "$USERNAME" ]; then
    sudo passwd "$USERNAME"
fi
