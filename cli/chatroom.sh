#!/usr/bin/env bash

SUPABASE_URL="https://thdzrkzdkdihjximoalb.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZHpya3pka2RpaGp4aW1vYWxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNDkzNzIsImV4cCI6MjA3NTgyNTM3Mn0.uHpGricbNHVWsndClTd8K7LVRTCzWLF0ziwuGKvOSTw"
REFRESH_RATE=5
USERNAME="$1"
LAST_ID=0
HISTORY_LIMIT=50
SYS_MSG_LINE=0

clear
echo -e "\e[36m💬 Dawn Chatroom"
echo "Commands: /exit set-refreshrate-<seconds>"
echo "------------------------------"

initial_msgs=$(curl -s "$SUPABASE_URL/rest/v1/chat?select=*&order=id.asc&limit=$HISTORY_LIMIT" -H "apikey: $SUPABASE_KEY" -H "Content-Type: application/json")
if [[ -n "$initial_msgs" ]]; then
    echo "$initial_msgs" | jq -r '.[] | "\(.created_at) | \(.username): \(.message)"'
    LAST_ID=$(echo "$initial_msgs" | jq -r '.[-1].id')
fi

echo "------------------------------"

upsert_active_user() {
    curl -s -X POST "$SUPABASE_URL/rest/v1/active_users" -H "apikey: $SUPABASE_KEY" -H "Content-Type: application/json" -d "{\"username\":\"$USERNAME\",\"last_seen\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > /dev/null
}

fetch_active_users() {
    local users
    users=$(curl -s "$SUPABASE_URL/rest/v1/active_users?select=username,last_seen" -H "apikey: $SUPABASE_KEY" -H "Content-Type: application/json" | jq -r --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.[] | select((now | fromdateiso8601) - (.last_seen | fromdateiso8601) < 30) | .username')
    local count
    count=$(echo "$users" | wc -l)
    echo -e "\e[33mActive users: $count ($users)\e[0m"
}

fetch_new_messages() {
    local resp new_msgs
    resp=$(curl -s "$SUPABASE_URL/rest/v1/chat?select=*&order=id.asc&limit=1000" -H "apikey: $SUPABASE_KEY" -H "Content-Type: application/json")
    new_msgs=$(echo "$resp" | jq -r --argjson last "$LAST_ID" '.[] | select(.id > $last) | "\(.created_at) | \(.username): \(.message)"')
    if [[ -n "$new_msgs" ]]; then
        echo "$new_msgs"
        LAST_ID=$(echo "$resp" | jq -r '.[-1].id')
    fi
}

print_sys_msg() {
    local msg="$1"
    echo -e "\e[32m$msg\e[0m"
    sleep 3
    tput cuu1
    tput el
}

refresh_loop() {
    while true; do
        upsert_active_user
        fetch_active_users
        fetch_new_messages
        echo -n "You: "
        sleep "$REFRESH_RATE"
    done
}

refresh_loop &
REFRESH_PID=$!

trap "kill $REFRESH_PID 2>/dev/null" EXIT

echo -n "You: "
while true; do
    read -r msg
    if [[ "$msg" == "/exit" ]]; then
        break
    elif [[ "$msg" =~ ^set-refreshrate-([0-9]+)$ ]]; then
        REFRESH_RATE="${BASH_REMATCH[1]}"
        print_sys_msg "Refresh rate set to $REFRESH_RATE"
        echo -n "You: "
        continue
    elif [[ -n "$msg" ]]; then
        json=$(jq -n --arg u "$USERNAME" --arg m "$msg" '{username:$u, message:$m}')
        curl -s "$SUPABASE_URL/rest/v1/chat" -H "apikey: $SUPABASE_KEY" -H "Content-Type: application/json" -d "$json" > /dev/null
        LAST_ID=$(curl -s "$SUPABASE_URL/rest/v1/chat?select=id&order=id.desc&limit=1" -H "apikey: $SUPABASE_KEY" -H "Content-Type: application/json" | jq -r '.[0].id')
    fi
done
