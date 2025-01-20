#!/bin/bash

# clear the screen
clear

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'
BOLD='\033[1m'

# Function to display a summary header
print_header() {
    echo -e "${BOLD}${GREEN}==== Cybersecurity Police Investigation Report ====${RESET}"
    echo -e "${BOLD}${YELLOW}Date: $(date)${RESET}\n"
}

# Function to check for failed login attempts
check_failed_logins() {
    echo -e "${BOLD}Checking for failed login attempts...${RESET}"
    failed_logins=$(grep 'Failed password' /var/log/auth.log | tail -n 10)
    if [ -z "$failed_logins" ]; then
        echo -e "${GREEN}No failed login attempts found.${RESET}"
        failed_logins_status="No evidence"
    else
        echo -e "${RED}$failed_logins${RESET}"
        failed_logins_status="Evidence found"
    fi
}

# Function to check for unusual root logins
check_root_logins() {
    echo -e "${BOLD}Checking for root logins...${RESET}"
    root_logins=$(grep 'root' /var/log/auth.log | grep 'session opened' | tail -n 10)
    if [ -z "$root_logins" ]; then
        echo -e "${GREEN}No unusual root logins found.${RESET}"
        root_logins_status="No evidence"
    else
        echo -e "${RED}$root_logins${RESET}"
        root_logins_status="Evidence found"
    fi
}

# Function to check for unusual sudo usage
check_sudo_usage() {
    echo -e "${BOLD}Checking for unusual sudo usage...${RESET}"
    sudo_usage=$(grep 'sudo' /var/log/auth.log | tail -n 10)
    if [ -z "$sudo_usage" ]; then
        echo -e "${GREEN}No unusual sudo usage found.${RESET}"
        sudo_usage_status="No evidence"
    else
        echo -e "${RED}$sudo_usage${RESET}"
        sudo_usage_status="Evidence found"
    fi
}

# Function to check for suspicious commands in bash history
check_history() {
    echo -e "${BOLD}Checking bash history for suspicious commands...${RESET}"
    if [ -f ~/.bash_history ]; then
        suspicious_commands=$(cat ~/.bash_history | grep -iE 'nc|nmap|wget|curl|bash|ssh|keylogger')
        if [ -z "$suspicious_commands" ]; then
            echo -e "${GREEN}No suspicious commands found in history.${RESET}"
            history_status="No evidence"
        else
            echo -e "${RED}$suspicious_commands${RESET}"
            history_status="Evidence found"
        fi
    else
        echo -e "${RED}No .bash_history file found. It may have been deleted or never created.${RESET}"
        history_status="Potential evidence (history file missing)"
    fi
}

# Function to check for suspicious processes
check_processes() {
    echo -e "${BOLD}Checking for suspicious processes...${RESET}"
    suspicious_processes=$(ps aux | sort -rk 3,3 | head -n 10)  # Sort by %CPU (column 3)
    if [ -z "$suspicious_processes" ]; then
        echo -e "${GREEN}No suspicious processes found.${RESET}"
        processes_status="No evidence"
    else
        echo -e "${RED}$suspicious_processes${RESET}"
        processes_status="Evidence found"
    fi
}

# Function to check for unexpected file modifications
check_file_modifications() {
    echo -e "${BOLD}Checking for unexpected file modifications...${RESET}"

    # Specify important directories to search
    directories_to_check="/etc /var/log /home"

    # Exclude directories like /proc, /sys, /dev that don't need to be searched
    file_modifications=$(find $directories_to_check -type f -ctime -1 2>/dev/null)  # Adjusted time window to 1 day

    if [ -z "$file_modifications" ]; then
        echo -e "${GREEN}No recent file modifications found.${RESET}"
        file_modifications_status="No evidence"
    else
        echo -e "${RED}$file_modifications${RESET}"
        file_modifications_status="Evidence found"
    fi
}

# Function to check for cron jobs
check_cron_jobs() {
    echo -e "${BOLD}Checking for unusual cron jobs...${RESET}"
    cron_jobs=$(crontab -l; cat /etc/crontab; ls -l /etc/cron.*)
    if [ -z "$cron_jobs" ]; then
        echo -e "${GREEN}No unusual cron jobs found.${RESET}"
        cron_jobs_status="No evidence"
    else
        echo -e "${RED}$cron_jobs${RESET}"
        cron_jobs_status="Evidence found"
    fi
}

# Function to check the last login details
check_last_login() {
    echo -e "${BOLD}Checking the last login details...${RESET}"
    if command -v last >/dev/null 2>&1; then
        last_login=$(last -n 10)
        if [ -z "$last_login" ]; then
            echo -e "${GREEN}No suspicious logins found.${RESET}"
            last_login_status="No evidence"
        else
            echo -e "${RED}$last_login${RESET}"
            last_login_status="Evidence found"
        fi
    else
        echo -e "${RED}last command not found. Using 'who' instead.${RESET}"
        last_login=$(who -u)
        if [ -z "$last_login" ]; then
            echo -e "${GREEN}No suspicious logins found.${RESET}"
            last_login_status="No evidence"
        else
            echo -e "${RED}$last_login${RESET}"
            last_login_status="Evidence found"
        fi
    fi
}

# Function to evaluate the evidence collected
evaluate_evidence() {
    total_evidence=0
    total_checks=0

    # Run all checks and sum up the results
    check_failed_logins
    ((total_checks++))
    if [ "$failed_logins_status" == "Evidence found" ]; then ((total_evidence++)); fi

    check_root_logins
    ((total_checks++))
    if [ "$root_logins_status" == "Evidence found" ]; then ((total_evidence++)); fi

    check_sudo_usage
    ((total_checks++))
    if [ "$sudo_usage_status" == "Evidence found" ]; then ((total_evidence++)); fi

    check_history
    ((total_checks++))
    if [[ "$history_status" == "Evidence found" || "$history_status" == "Potential evidence (history file missing)" ]]; then ((total_evidence++)); fi

    check_processes
    ((total_checks++))
    if [ "$processes_status" == "Evidence found" ]; then ((total_evidence++)); fi

    check_file_modifications
    ((total_checks++))
    if [ "$file_modifications_status" == "Evidence found" ]; then ((total_evidence++)); fi

    check_cron_jobs
    ((total_checks++))
    if [ "$cron_jobs_status" == "Evidence found" ]; then ((total_evidence++)); fi

    # Comment out this check if you don't want to display open ports
    # check_open_ports
    # ((total_checks++))
    # if [ "$open_ports_status" == "Evidence found" ]; then ((total_evidence++)); fi

    check_last_login
    ((total_checks++))
    if [ "$last_login_status" == "Evidence found" ]; then ((total_evidence++)); fi

    # Determine if there's enough evidence
    echo -e "\n${BOLD}Conclusion:${RESET}"
    if [ "$total_evidence" -ge 5 ]; then
        echo -e "${GREEN}Sufficient evidence found! The traces could likely be used as proof against the hacker.${RESET}"
    else
        echo -e "${RED}Insufficient evidence. More investigation is needed to identify traces strong enough to be used as proof.${RESET}"
    fi
}

# Main function to run all checks and evaluate evidence
main() {
    print_header
    evaluate_evidence
    echo -e "\n${BOLD}${YELLOW}Investigation completed.${RESET}"
}

# Run the main function
main
