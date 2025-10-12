#!/usr/bin/env bash
clear
echo -e "\e[32m"
echo "============================"
echo "        Dawn System         "
echo "============================"
echo
echo "1. View Targets"
echo "2. Chatroom"
echo "3. Exit"
read -p "Select option: " opt

if [ "$opt" = "1" ]; then
  echo "Showing targets..."
  sleep 1
  echo "[REDACTED]  — Classified targets list."
elif [ "$opt" = "2" ]; then
  echo "Opening chatroom..."
  sleep 1
  echo "Chatroom coming soon..."
else
  echo "Exiting.."
  sleep 2
fi
