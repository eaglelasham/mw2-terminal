#!/usr/bin/env bash

SUPABASE_URL="https://thdzrkzdkdihjximoalb.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZHpya3pka2RpaGp4aW1vYWxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNDkzNzIsImV4cCI6MjA3NTgyNTM3Mn0.uHpGricbNHVWsndClTd8K7LVRTCzWLF0ziwuGKvOSTw"

clear
echo -e "\e[36m💬 Dawn Chatroom"
echo "Type '/exit' to leave the chat."
echo "------------------------------"

while true; do
    # Fetch last 10 messages
    resp=$(curl -s "$SUPABASE_URL/rest/v1/chat?select=*&order=created_at.desc&limit=10" \
        -H "apikey: $SUPABASE_KEY" \
        -H "Content-Type: application/json")
    
    clear
    echo -e "\e[36m💬 Dawn Chatroom (last 10 messages)"
    echo "------------------------------"
    echo "$resp" | jq -r '.[] | "\(.username): \(.message)"'
    echo "------------------------------"

    read -p "You: " msg
    if [ "$msg" = "/exit" ]; then
        break
    fi

    # Post message
    read -p "Enter your codename: " USER
    json=$(jq -n --arg u "$USER" --arg m "$msg" '{username:$u, message:$m}')
    curl -s "$SUPABASE_URL/rest/v1/chat" \
        -H "apikey: $SUPABASE_KEY" \
        -H "Content-Type: application/json" \
        -d "$json" > /dev/null
done
