#!/usr/bin/env bash

SUPABASE_URL="https://thdzrkzdkdihjximoalb.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZHpya3pka2RpaGp4aW1vYWxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNDkzNzIsImV4cCI6MjA3NTgyNTM3Mn0.uHpGricbNHVWsndClTd8K7LVRTCzWLF0ziwuGKvOSTw"

clear
echo -e "\e[32m"

echo "Dawn's Server"

read -p "Username: " USER
read -s -p "Password: " PASS
echo

resp=$(curl -s "$SUPABASE_URL/rest/v1/users?username=eq.$USER" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Content-Type: application/json")

found_pass=$(echo "$resp" | jq -r '.[0].password // empty')

if [ -z "$found_pass" ]; then
  sleep 2
  echo "User not found."
  exit 1
fi

if [ "$PASS" = "$found_pass" ]; then
  clear
  echo "Login success!"
  sleep 2
  bash menu.sh
else
  clear
  echo "Wrong password."
  sleep 2
fi
