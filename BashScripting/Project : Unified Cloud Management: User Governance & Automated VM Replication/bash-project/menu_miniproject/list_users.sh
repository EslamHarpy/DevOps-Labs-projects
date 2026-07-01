#!/bin/bash
USERS_LIST=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd)
whiptail --title "System Users" --msgbox "$USERS_LIST" 20 50
