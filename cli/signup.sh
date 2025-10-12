#!/usr/bin/env bash
SUPABASE_URL="https://thdzrkzdkdihjximoalb.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZHpya3pka2RpaGp4aW1vYWxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNDkzNzIsImV4cCI6MjA3NTgyNTM3Mn0.uHpGricbNHVWsndClTd8K7LVRTCzWLF0ziwuGKvOSTw"

clear
echo -e "\e[32m"
read -p "Create username: " USER
read -s -p "Create password: " PASS
echo "Creating Account.."

json=$(jq -n --arg u "$USER" --arg p "$PASS" '{username:$u, password:$p}')

resp=$(curl -s "$SUPABASE_URL/rest/v1/users" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d "$json")
clear
echo "Signup complete."
