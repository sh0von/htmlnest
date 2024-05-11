#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'  # No color

# Define the target directory for the executable script
INSTALL_DIR="/usr/local/bin"

# Function to display installation animation
show_installation_animation() {
    printf "${GREEN}Installing htmlnest command...${NC}\n"
    printf "${YELLOW}#####                     (25%%)\r${NC}"
    sleep 0.5
    printf "${YELLOW}#############             (50%%)\r${NC}"
    sleep 0.5
    printf "${YELLOW}####################      (75%%)\r${NC}"
    sleep 0.5
    printf "${YELLOW}##########################(100%%)\r${NC}\n"
}

# Function to display installation status
installation_status() {
    if [ $? -eq 0 ]; then
        printf "${NC}htmlnest command has been installed successfully in $INSTALL_DIR${NC}\n"
        printf "You can now use ${GREEN}'htmlnest'${NC} command globally.\n"
    else
        printf "${RED}Installation failed. Please try again.${NC}\n"
    fi
}

# Ensure the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    printf "${RED}Please run this script with sudo or as root.${NC}\n"
    exit 1
fi

# Check if the target directory exists; if not, create it
if [ ! -d "$INSTALL_DIR" ]; then
    printf "${YELLOW}Creating directory: $INSTALL_DIR${NC}\n"
    mkdir -p "$INSTALL_DIR"
fi

# Display installation animation
show_installation_animation

# Copy the htmlnest script to the installation directory
printf "${GREEN}Copying htmlnest script to $INSTALL_DIR${NC}\n"
cp htmlnest.sh "$INSTALL_DIR/htmlnest"

# Set execute permissions for the copied script
chmod +x "$INSTALL_DIR/htmlnest"

# Display installation status
installation_status
