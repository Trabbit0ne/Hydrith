#!/usr/bin/env bash

clear

# === OS DETECTION ===
IS_WINDOWS=false
UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    CYGWIN*|MINGW*|MSYS*|Windows_NT*)
        IS_WINDOWS=true
        ;;
esac

# === COLORS ===
BLACK="\e[30m"
WHITE="\e[97m"
GRAY="\e[90m"
GREEN="\e[1;32m"
RED="\e[31m"
NE="\e[0m"

INFO="${WHITE}[INFO]${NE}"
SUCCESS="${GREEN}[SUCCESS]${NE}"
ERROR="${RED}[ERROR]${NE}"
ARROW="${WHITE} ➜${NE}"

# === TIMESTAMP ===
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# === ROOT CHECK ===
if [[ $EUID -ne 0 && "$IS_WINDOWS" = false ]]; then
    echo -e "${ERROR} This script must be run as root. Exiting."
    exit 1
fi

# === GLOBAL VARS ===
backup_dir="/tmp/backup_$(date +%s)"
mkdir -p "$backup_dir"

important_files=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/group"
    "/etc/sudoers"
    "/var/log/auth.log"
    "/var/log/secure"
    "/var/log/syslog"
    "/var/log/messages"
    "$HOME/.bash_history"
)

# === FUNCTIONS ===

progress_bar() {
    local total=25
    local delay=0.003
    local current=0

    while [ $current -le $total ]; do
        local filled=$(printf '█%.0s' $(seq 1 $current))
        local empty=$(printf ' %.0s' $(seq 1 $((total - current))))
        echo -ne "Progress: [${filled}${empty}] \r"
        sleep $delay
        ((current++))
    done
    echo -e "Progress: [$(printf '█%.0s' $(seq 1 $total))] Complete"
}

banner() {
cat <<EOF
                ,__~______________________~__,
                |____________________________|]
                /____________________________;
                    |  \]__/ /_____________;
                   /     ,--'
                  /     /
                 |_____/
                 \____;

                Created By Trabbit0ne

======================================================
EOF
}

backup_important_files() {
    echo -e "${WHITE}[$(timestamp)] Backing up important files...${NE}"
    for file in "${important_files[@]}"; do
        if [ -e "$file" ]; then
            cp --preserve=timestamps "$file" "$backup_dir/"
            echo -e "${ARROW} Backed up: $file"
        fi
    done
    echo -e "${SUCCESS} Backup completed.${NE}\n"
}

restore_important_files() {
    echo -e "${WHITE}[$(timestamp)] Restoring backed up files...${NE}"
    for file in "${important_files[@]}"; do
        backup_file="$backup_dir/$(basename "$file")"
        if [ -e "$backup_file" ]; then
            cp --preserve=timestamps "$backup_file" "$file"
            echo -e "${ARROW} Restored: $file"
        fi
    done
    echo -e "${SUCCESS} Files restored and ctime reset.${NE}\n"
}

generate_fake_logs() {
    echo -e "${WHITE}[$(timestamp)] Generating fake logs for testing...${NE}"
    logs=(
        "/var/log/auth.log"
        "/var/log/syslog"
        "/var/log/messages"
        "/var/log/cron"
        "/var/log/apache2"
    )
    progress_bar
    for logfile in "${logs[@]}"; do
        if [ -d "$logfile" ]; then
            echo -e "${ARROW} Writing to: $logfile/fake.log"
            echo "Fake log entry at $(date)" >> "$logfile/fake.log"
        elif [ -f "$logfile" ]; then
            echo -e "${ARROW} Writing to: $logfile"
            echo "Fake log entry at $(date)" >> "$logfile"
        else
            mkdir -p "$logfile" && echo -e "${ARROW} Created directory: $logfile"
        fi
    done
    echo -e "${SUCCESS} Fake logs generated.${NE}\n"
}

clear_history() {
    echo -e "${WHITE}[$(timestamp)] Clearing command history...${NE}"
    if [ "$IS_WINDOWS" = false ]; then
        history -c && history -w
        export HISTSIZE=0
        export HISTFILESIZE=0
        rm -f "$HOME/.bash_history" "$HOME/.zsh_history"
        touch -d "$(date)" "$HOME/.bash_history" "$HOME/.zsh_history"
        echo -e "${SUCCESS} Command history cleared.${NE}\n"
    else
        echo -e "${INFO} Skipping history clear: Not supported on Windows.${NE}"
    fi
}

wipe_temp_files() {
    echo -e "${WHITE}[$(timestamp)] Wiping temporary files...${NE}"
    progress_bar
    if [ "$IS_WINDOWS" = false ]; then
        rm -rf /tmp/* /var/tmp/*
        touch -d "$(date)" /tmp /var/tmp
        echo -e "${SUCCESS} Temporary files wiped and timestamps reset.${NE}"
    else
        echo -e "${INFO} Skipping temp file wipe: Not supported on Windows.${NE}"
    fi
}

clear_swap() {
    echo -e "${WHITE}[$(timestamp)] Checking and clearing swap space...${NE}"
    if [ "$IS_WINDOWS" = false ]; then
        if grep -q "swap" /proc/swaps; then
            swapoff -a
            echo -e "${SUCCESS} Swap space cleared.${NE}\n"
        else
            echo -e "${INFO} No swap space detected.${NE}\n"
        fi
    else
        echo -e "${INFO} Skipping swap clear: Not supported on Windows.${NE}\n"
    fi
}

reset_timestamps() {
    echo -e "${WHITE}[$(timestamp)] Resetting file timestamps to original...${NE}"
    if [ "$IS_WINDOWS" = false ]; then
        find /var/log /tmp /var/tmp -type f -exec touch -d "$(date)" {} \;
        echo -e "${SUCCESS} Timestamps reset for logs and temp files.${NE}\n"
    else
        echo -e "${INFO} Skipping timestamp reset: Not supported on Windows.${NE}\n"
    fi
}

full_cleanup_and_fake_logs() {
    echo -e "${WHITE}[$(timestamp)] Starting full cleanup and log generation...${NE}"
    backup_important_files
    clear_history
    wipe_temp_files
    clear_swap
    generate_fake_logs
    reset_timestamps
    restore_important_files
    echo -e "${SUCCESS} Full cleanup and log generation complete.${NE}\n"
}

main() {
    banner
    full_cleanup_and_fake_logs
}

main
