#!/bin/bash

# Laravel EOL Checker
# Checks the Laravel version in a repository and displays EOL information

set -e

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# API endpoint
EOL_API="https://endoflife.date/api/laravel.json"

# Function to print colored output
print_header() {
    echo -e "${BOLD}${BLUE}==================================${NC}"
    echo -e "${BOLD}${BLUE}  Laravel EOL Status Checker${NC}"
    echo -e "${BOLD}${BLUE}==================================${NC}\n"
}

print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_info() {
    echo -e "${CYAN}$1${NC}"
}

# Check if required commands are available
check_dependencies() {
    local missing_deps=()
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install them using:"
        echo "  Ubuntu/Debian: sudo apt-get install ${missing_deps[*]}"
        echo "  macOS: brew install ${missing_deps[*]}"
        exit 1
    fi
}

# Check if composer.lock exists
check_composer_lock() {
    if [ ! -f "composer.lock" ]; then
        print_error "composer.lock not found in current directory"
        echo "Please run this script from the root of a Laravel project"
        exit 1
    fi
}

# Extract Laravel version from composer.lock
get_laravel_version() {
    local version
    version=$(jq -r '.packages[] | select(.name == "laravel/framework") | .version' composer.lock 2>/dev/null)
    
    if [ -z "$version" ] || [ "$version" == "null" ]; then
        print_error "Laravel framework not found in composer.lock"
        exit 1
    fi
    
    echo "$version"
}

# Extract major version from full version string
get_major_version() {
    local full_version="$1"
    # Remove 'v' prefix if present and extract major version
    echo "$full_version" | sed 's/^v//' | cut -d'.' -f1
}

# Fetch EOL data from API
fetch_eol_data() {
    local temp_file="/tmp/laravel-eol-$$.json"
    
    if ! curl -s -f "$EOL_API" -o "$temp_file" 2>/dev/null; then
        print_error "Failed to fetch EOL data from $EOL_API"
        rm -f "$temp_file"
        exit 1
    fi
    
    echo "$temp_file"
}

# Get EOL info for specific version
get_version_eol_info() {
    local eol_file="$1"
    local major_version="$2"
    
    jq -r --arg ver "$major_version" '.[] | select(.cycle == $ver)' "$eol_file"
}

# Calculate days until date
days_until() {
    local target_date="$1"
    local today=$(date +%s)
    local target=$(date -d "$target_date" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$target_date" +%s 2>/dev/null)
    
    if [ -z "$target" ]; then
        echo "N/A"
        return
    fi
    
    local diff_days=$(( (target - today) / 86400 ))
    echo "$diff_days"
}

# Format date for display
format_date() {
    local date_str="$1"
    if [ "$date_str" == "null" ] || [ -z "$date_str" ]; then
        echo "N/A"
        return
    fi
    
    # Try to format the date nicely
    date -d "$date_str" "+%B %d, %Y" 2>/dev/null || date -j -f "%Y-%m-%d" "$date_str" "+%B %d, %Y" 2>/dev/null || echo "$date_str"
}

# Display version information
display_version_info() {
    local full_version="$1"
    local major_version="$2"
    local eol_info="$3"
    
    echo -e "${BOLD}Repository Information:${NC}"
    echo -e "  Project Path: ${CYAN}$(pwd)${NC}"
    echo ""
    
    echo -e "${BOLD}Laravel Version:${NC}"
    echo -e "  Installed Version: ${CYAN}${full_version}${NC}"
    echo -e "  Major Version: ${CYAN}${major_version}${NC}"
    echo ""
    
    if [ -z "$eol_info" ]; then
        print_warning "No EOL data found for Laravel $major_version"
        return
    fi
    
    # Parse EOL data
    local release_date=$(echo "$eol_info" | jq -r '.releaseDate // .release // "null"')
    local support_date=$(echo "$eol_info" | jq -r '.support // "null"')
    local eol_date=$(echo "$eol_info" | jq -r '.eol // "null"')
    local latest_version=$(echo "$eol_info" | jq -r '.latest // "null"')
    local lts=$(echo "$eol_info" | jq -r '.lts // false')
    
    echo -e "${BOLD}Support Information:${NC}"
    echo -e "  Latest ${major_version}.x Release: ${CYAN}${latest_version}${NC}"
    
    if [ "$lts" == "true" ]; then
        echo -e "  Release Type: ${GREEN}LTS (Long Term Support)${NC}"
    else
        echo -e "  Release Type: Standard Release"
    fi
    
    echo ""
    echo -e "${BOLD}Important Dates:${NC}"
    echo -e "  Released: $(format_date "$release_date")"
    
    # Active support status
    if [ "$support_date" != "null" ] && [ -n "$support_date" ]; then
        local support_formatted=$(format_date "$support_date")
        local days_to_support=$(days_until "$support_date")
        
        echo -n "  Active Support Until: $support_formatted"
        
        if [ "$days_to_support" != "N/A" ]; then
            if [ "$days_to_support" -lt 0 ]; then
                echo -e " ${RED}(ENDED)${NC}"
            elif [ "$days_to_support" -lt 90 ]; then
                echo -e " ${RED}(${days_to_support} days remaining)${NC}"
            elif [ "$days_to_support" -lt 180 ]; then
                echo -e " ${YELLOW}(${days_to_support} days remaining)${NC}"
            else
                echo -e " ${GREEN}(${days_to_support} days remaining)${NC}"
            fi
        else
            echo ""
        fi
    fi
    
    # Security support status
    if [ "$eol_date" != "null" ] && [ -n "$eol_date" ]; then
        local eol_formatted=$(format_date "$eol_date")
        local days_to_eol=$(days_until "$eol_date")
        
        echo -n "  Security Fixes Until: $eol_formatted"
        
        if [ "$days_to_eol" != "N/A" ]; then
            if [ "$days_to_eol" -lt 0 ]; then
                echo -e " ${RED}(END OF LIFE)${NC}"
            elif [ "$days_to_eol" -lt 90 ]; then
                echo -e " ${RED}(${days_to_eol} days remaining)${NC}"
            elif [ "$days_to_eol" -lt 180 ]; then
                echo -e " ${YELLOW}(${days_to_eol} days remaining)${NC}"
            else
                echo -e " ${GREEN}(${days_to_eol} days remaining)${NC}"
            fi
        else
            echo ""
        fi
    fi
    
    echo ""
}

# Display recommendations
display_recommendations() {
    local major_version="$1"
    local eol_info="$2"
    local latest_major="$3"
    
    local support_date=$(echo "$eol_info" | jq -r '.support // "null"')
    local eol_date=$(echo "$eol_info" | jq -r '.eol // "null"')
    local days_to_support=$(days_until "$support_date")
    local days_to_eol=$(days_until "$eol_date")
    
    echo -e "${BOLD}Recommendations:${NC}"
    
    # Check if version is EOL
    if [ "$days_to_eol" != "N/A" ] && [ "$days_to_eol" -lt 0 ]; then
        echo -e "  ${RED}⚠ CRITICAL: This version is no longer supported!${NC}"
        echo -e "  ${RED}⚠ No security updates are being released.${NC}"
        echo -e "  Action: Upgrade to Laravel $latest_major immediately"
    elif [ "$days_to_eol" != "N/A" ] && [ "$days_to_eol" -lt 90 ]; then
        echo -e "  ${RED}⚠ URGENT: Security support ends in less than 90 days!${NC}"
        echo -e "  Action: Plan upgrade to Laravel $latest_major soon"
    elif [ "$days_to_support" != "N/A" ] && [ "$days_to_support" -lt 0 ]; then
        echo -e "  ${YELLOW}⚠ Active support has ended (security fixes only)${NC}"
        echo -e "  Action: Consider upgrading to Laravel $latest_major"
    elif [ "$days_to_support" != "N/A" ] && [ "$days_to_support" -lt 180 ]; then
        echo -e "  ${YELLOW}⚠ Active support ends in less than 6 months${NC}"
        echo -e "  Action: Start planning upgrade to Laravel $latest_major"
    else
        echo -e "  ${GREEN}✓ Your Laravel version is currently supported${NC}"
        
        if [ "$major_version" != "$latest_major" ]; then
            echo -e "  Info: Latest major version is Laravel $latest_major"
        fi
    fi
    
    echo ""
    echo -e "  Upgrade Guide: ${CYAN}https://laravel.com/docs/${latest_major}.x/upgrade${NC}"
    echo -e "  Release Notes: ${CYAN}https://laravel.com/docs/${latest_major}.x/releases${NC}"
}

# Get the latest major version from EOL data
get_latest_major_version() {
    local eol_file="$1"
    jq -r '[.[] | select(.eol != false)] | max_by(.cycle | tonumber) | .cycle' "$eol_file"
}

# Main function
main() {
    print_header
    
    # Check dependencies
    check_dependencies
    
    # Check for composer.lock
    check_composer_lock
    
    print_info "Analyzing Laravel installation...\n"
    
    # Get Laravel version
    local full_version=$(get_laravel_version)
    local major_version=$(get_major_version "$full_version")
    
    print_info "Fetching EOL data from endoflife.date...\n"
    
    # Fetch EOL data
    local eol_file=$(fetch_eol_data)
    
    # Get EOL info for this version
    local eol_info=$(get_version_eol_info "$eol_file" "$major_version")
    
    # Get latest major version
    local latest_major=$(get_latest_major_version "$eol_file")
    
    # Display information
    display_version_info "$full_version" "$major_version" "$eol_info"
    
    if [ -n "$eol_info" ]; then
        display_recommendations "$major_version" "$eol_info" "$latest_major"
    fi
    
    # Cleanup
    rm -f "$eol_file"
    
    # Exit with appropriate code
    if [ -n "$eol_info" ]; then
        local eol_date=$(echo "$eol_info" | jq -r '.eol // "null"')
        local days_to_eol=$(days_until "$eol_date")
        
        if [ "$days_to_eol" != "N/A" ] && [ "$days_to_eol" -lt 0 ]; then
            exit 2  # EOL
        elif [ "$days_to_eol" != "N/A" ] && [ "$days_to_eol" -lt 90 ]; then
            exit 1  # Warning
        fi
    fi
    
    exit 0
}

# Run main function
main "$@"
