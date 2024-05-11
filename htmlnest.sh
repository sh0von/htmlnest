#!/bin/bash

# ANSI color codes for terminal output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'  # Reset color

# Log files
LOG_FILE="htmlnest.log"
ERROR_LOG="error.log"

# Function to display usage instructions
usage() {
    echo -e "Usage: ${GREEN}htmlnest${NC} ${YELLOW}[-x]${NC} ${YELLOW}[-n]${NC} ${YELLOW}[-l]${NC}"
    echo "Scan and organize an HTML project by moving files into separate directories based on file types."
    echo -e "\nOptions:"
    echo -e "  ${GREEN}-x${NC}  Execute the scan and organize operation in the current directory."
    echo -e "         This option moves files into their respective directories based on file types."
    echo -e "\n  ${GREEN}-n${NC}  Perform a dry-run (simulate without moving files)."
    echo -e "         Use with ${GREEN}-x${NC} option to preview file movements before execution."
    echo -e "\n  ${GREEN}-l${NC}  Display the contents of the log file."
    echo -e "         View a record of file movements stored in the log file."
}

# Function to log messages with timestamps
log_message() {
    local log_file="$1"
    local message="$2"
    local log_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "${log_timestamp} - ${message}" >> "$log_file"
}

# Parse command-line options
while getopts ":xnl" opt; do
    case $opt in
        x)
            EXECUTE=true
            ;;
        n)
            DRY_RUN=true
            ;;
        l)
            DISPLAY_LOG=true
            ;;
        :)
            echo -e "${RED}Error: Option -$OPTARG requires an argument.${NC}"
            usage
            exit 1
            ;;
        \?)
            echo -e "${RED}Error: Invalid option -$OPTARG.${NC}"
            usage
            exit 1
            ;;
    esac
done

# Check for -n without -x
if [ "$DRY_RUN" = true ] && [ "$EXECUTE" != true ]; then
    echo -e "${RED}Error: Option -n must be used with -x to perform a dry-run.${NC}"
    usage
    exit 1
fi

# If 'log' command option is specified, display the contents of the log file
if [ "$DISPLAY_LOG" = true ]; then
    echo -e "${GREEN}Log File Contents:${NC}"
    if [ -f "$LOG_FILE" ]; then
        cat "$LOG_FILE"
    else
        echo -e "${YELLOW}Log file not found or empty.${NC}"
    fi
    exit 0
fi

# If no valid options provided or unrecognized arguments, display usage instructions
if [ $OPTIND -eq 1 ]; then
    usage
    exit 0
fi

# List of file types and their corresponding directories
declare -A FILE_TYPES=(
    ["css"]="CSS"
    ["scss"]="CSS"
    ["sass"]="CSS"
    ["less"]="CSS"
    ["styl"]="CSS"
    ["js"]="JS"
    ["jsx"]="JS"
    ["ts"]="JS"
    ["tsx"]="JS"
    ["jpg"]="Images"
    ["jpeg"]="Images"
    ["png"]="Images"
    ["gif"]="Images"
    ["svg"]="Images"
    ["woff"]="Fonts"
    ["woff2"]="Fonts"
    ["ttf"]="Fonts"
    ["otf"]="Fonts"
    ["eot"]="Fonts"
    ["mp4"]="Videos"
    ["avi"]="Videos"
    ["mov"]="Videos"
    ["mkv"]="Videos"
)

# Dry-run or actual file movement
move_files() {
    local dry_run="$1"
    local found_files=false

    for ext in "${!FILE_TYPES[@]}"; do
        files=$(find . -maxdepth 1 -type f -name "*.$ext" | wc -l)
        if [ "$files" -gt 0 ]; then
            file_type="${FILE_TYPES[$ext]}"
            echo -e "${GREEN}Files to be moved (${ext^^}):${NC}"
            while IFS= read -r file; do
                found_files=true
                dest_dir="${file_type}/"

                if [ "$dry_run" = true ]; then
                    echo -e "${YELLOW}$(basename "$file") => ${dest_dir}$(basename "$file")${NC}"
                else
                    mkdir -p "$dest_dir"  # Create destination directory if it doesn't exist
                    if [ ! -d "$dest_dir" ]; then
                        log_message "$ERROR_LOG" "Error: Destination directory '$dest_dir' not found."
                        continue
                    fi
                    mv -v "$file" "$dest_dir" || log_message "$ERROR_LOG" "Error: Failed to move ${ext} file '$file'."
                    # Log file movement details
                    log_message "$LOG_FILE" "Moved '${file}' to '${dest_dir}$(basename "$file")'"
                fi
            done < <(find . -maxdepth 1 -type f -name "*.$ext")
        fi
    done

    if [ "$found_files" = false ]; then
        echo -e "${YELLOW}No files found to move.${NC}"
    fi
}

# Perform scan and organize operation if -x option is specified
if [ "$EXECUTE" = true ]; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}Dry-run mode enabled. Simulating file organization.${NC}"
        move_files true
    else
        echo -e "${GREEN}Committing changes.${NC}"
        move_files false
        echo -e "${GREEN}Project files organized successfully.${NC}"

        # Display summary of file movements
        echo -e "${GREEN}Summary:${NC}"
        echo -e "${GREEN}Files moved:${NC} $(grep -c 'Moved' "$LOG_FILE")"
        echo -e "${RED}Errors:${NC} $(wc -l < "$ERROR_LOG")"
    fi
fi

exit 0
