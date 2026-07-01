#!/bin/bash
GROUPNAME=$(whiptail --inputbox "Enter group name to delete:" 8 45 3>&1 1>&2 2>&3)
if [ ! -z "$GROUPNAME" ]; then
    sudo groupdel "$GROUPNAME" && whiptail --msgbox "Group $GROUPNAME deleted!" 8 45
fi
