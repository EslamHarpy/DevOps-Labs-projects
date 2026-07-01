#!/bin/bash
GROUPNAME=$(whiptail --inputbox "Enter the new group name:" 8 45 3>&1 1>&2 2>&3)
if [ ! -z "$GROUPNAME" ]; then
    sudo groupadd "$GROUPNAME" && whiptail --msgbox "Group $GROUPNAME created successfully!" 8 45
fi
