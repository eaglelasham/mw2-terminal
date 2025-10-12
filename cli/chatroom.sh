#!/usr/bin/env bash

SUPABASE_URL="https://thdzrkzdkdihjximoalb.supabase.co"
SUPABASE_KEY="YOUR_ANON_KEY_HERE"

REFRESH_RATE=5  # default refresh rate in seconds
USERNAME=""
LAST_ID=0       # keep track of the last displayed message
HISTORY_LIMIT=50  # show only last 50 messages

clear
echo -e "\e[36m💬 Dawn Chatroom"
echo "Commands:"
echo "  /exit                     — leave chatroom"
echo "  set-refreshrate-<seconds> — change refresh rate (e.g., set-refreshrate-10)"
echo "------------------------------"

read -p "Enter your username: " USERNAME

# Function to fetch messages with ID greater than LAST_ID
fetch_new_messages() {
    local resp
    resp=$(curl -s "$SUPABASE_URL/rest/v1/chat?select=*&order=id.asc&limit=1000" \
        -H "apikey: $SUPABASE_KEY" \
        -H "Content-Type: application/json")

    # Filter messages newer than LAST_ID
    new_msgs=$(echo "$resp" | jq -r --argjson last "$LAST_ID" '.[] | select(.id > $last) | "\(.created_at) | \(.username): \(.message)"')
    
    if [[ -n "$new_msgs" ]]; then
        # Print new messages
        echo "$new_msgs"
        # Update LAST_ID to newest message
        LAST_ID=$(echo "$resp" | jq -r '.[-1].id')
    fi
}

# Display last 50 messages initially
initial_msgs=$(curl -s "$SUPABASE_URL/rest/v1/chat?select=*&order=id.asc&limit=50" \
    -H "apikey: $SUPABASE_KEY" \
    -H "Content-Type: application/json")

if [[ -n "$initial_msgs" ]]; then
    echo "$initial_msgs" | jq -r '.[] | "\(.created_at) | \(.username): \(.message)"'
    LAST_ID=$(echo "$initial_msgs" | jq -r '.[-1].id')
fi

echo "------------------------------"
echo -n "You: "

# Background loop for auto-refresh (append-only)
refresh_loop() {
    while true; do
        new_messages=$(fetch_new_messages)
        if [[ -n "$new_messages" ]]; then
            echo "$new_messages"
            echo -n "You: "
        fi
        sleep "$REFRESH_RATE"
    done
}

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
        echo -n "You: "
        continue
    elif [[ -n "$msg" ]]; then
        json=$(jq -n --arg u "$USERNAME" --arg m "$msg" '{username:$u, message:$m}')
        curl -s "$SUPABASE_URL/rest/v1/chat" \
            -H "apikey: $SUPABASE_KEY" \
            -H "Content-Type: application/json" \
            -d "$json" > /dev/null
    fi
done
