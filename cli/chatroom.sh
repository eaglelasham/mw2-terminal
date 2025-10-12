#!/usr/bin/env bash

SUPABASE_URL="https://thdzrkzdkdihjximoalb.supabase.co"
SUPABASE_KEY="YOUR_ANON_KEY_HERE"

REFRESH_RATE=5  # default refresh rate in seconds
USERNAME=""

clear
echo -e "\e[36mLive Chatroom"
echo "Commands:"
echo "  /exit                     — leave chatroom"
echo "  set-refreshrate-<seconds> — change refresh rate (e.g., set-refreshrate-10)"
echo "------------------------------"

read -p "Enter your username: " USERNAME

# Function to fetch and display last 10 messages
fetch_messages() {
    local resp
    resp=$(curl -s "$SUPABASE_URL/rest/v1/chat?select=*&order=created_at.desc&limit=10" \
        -H "apikey: $SUPABASE_KEY" \
        -H "Content-Type: application/json")

    clear
    echo -e "\e[36m💬 Dawn Chatroom (last 10 messages, refresh every $REFRESH_RATE sec)"
    echo "------------------------------"
    echo "$resp" | jq -r '.[] | "\(.created_at) | \(.username): \(.message)"'
    echo "------------------------------"
    echo -n "You: "
}

# Background loop for auto-refresh
refresh_loop() {
    while true; do
        fetch_messages
        sleep "$REFRESH_RATE"
    done
}

# Start background refresh
refresh_loop &
REFRESH_PID=$!

# Trap to kill background refresh when exiting
trap "kill $REFRESH_PID 2>/dev/null" EXIT

# Main input loop
while true; do
    read -r msg
    if [[ "$msg" == "/exit" ]]; then
        break
    elif [[ "$msg" =~ ^set-refreshrate-([0-9]+)$ ]]; then
        REFRESH_RATE="${BASH_REMATCH[1]}"
        echo "Refresh rate set to $REFRESH_RATE seconds."
        sleep 1
        fetch_messages
        continue
    elif [[ -n "$msg" ]]; then
        json=$(jq -n --arg u "$USERNAME" --arg m "$msg" '{username:$u, message:$m}')
        curl -s "$SUPABASE_URL/rest/v1/chat" \
            -H "apikey: $SUPABASE_KEY" \
            -H "Content-Type: application/json" \
            -d "$json" > /dev/null
    fi
done
