#!/bin/bash
# Minimal bash CLI for chatting with a local Ollama model.
# No Python, no web UI — just curl + jq.
# Set MODEL env var to use a different model.

MODEL="${MODEL:-llama3.1:8b}"
API="${OLLAMA_URL:-http://localhost:11434/api/chat}"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RESET='\033[0m'

check_deps() {
    command -v curl &>/dev/null || { echo "Install curl: sudo apt install curl"; exit 1; }
    command -v jq &>/dev/null   || { echo "Install jq: sudo apt install jq"; exit 1; }
}

check_ollama() {
    curl -s http://localhost:11434 &>/dev/null || {
        echo "Ollama not running. Starting..."
        ollama serve &>/dev/null &
        sleep 2
    }
}

pull_model() {
    if ! ollama list 2>/dev/null | grep -q "$MODEL"; then
        echo "Pulling $MODEL (first time only)..."
        ollama pull "$MODEL"
    fi
}

chat() {
    MESSAGES="[]"
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}  AI Chat — model: $MODEL — type 'exit' to quit${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    while true; do
        echo ""
        printf "${GREEN}You: ${RESET}"
        read -r INPUT

        [[ "$INPUT" == "exit" || "$INPUT" == "quit" ]] && echo "Bye!" && exit 0
        [[ -z "$INPUT" ]] && continue

        MESSAGES=$(jq -n --argjson msgs "$MESSAGES" --arg txt "$INPUT" \
            '$msgs + [{"role":"user","content":$txt}]')

        REPLY=$(curl -s "$API" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$MODEL\",\"messages\":$MESSAGES,\"stream\":false}" \
            | jq -r '.message.content // "error: no response"')

        MESSAGES=$(jq -n --argjson msgs "$MESSAGES" --arg txt "$REPLY" \
            '$msgs + [{"role":"assistant","content":$txt}]')

        echo ""
        echo -e "${CYAN}AI:${RESET} $REPLY"
    done
}

check_deps
check_ollama
pull_model
chat
