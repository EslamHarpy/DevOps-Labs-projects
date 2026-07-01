#!/bin/bash
GROUPS_LIST=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd)
whiptail --title "System Groups" --msgbox "$GROUPS_LIST" 20 50
