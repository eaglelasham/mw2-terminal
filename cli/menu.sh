#!/usr/bin/env bash
clear
echo -e "\e[32m"
echo "============================"
echo "        Dawn System         "
echo "============================"

while true; do
    echo
    echo "1. View Targets"
    echo "2. Chatroom"
    echo "3. Exit"
    read -p "Select option: " opt

    case "$opt" in
        1)
            echo " Showing targets..."
            sleep 1
            echo "[REDACTED]  — Classified targets list."
            ;;
        2)
            bash chatroom.sh
            ;;
        3)
            echo "Exiting.."
            sleep 1
            exit 0
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
