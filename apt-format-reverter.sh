#!/bin/bash

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
INFO="${YELLOW}[INFO]${NC}"
ERROR="${RED}[ERROR]${NC}"
SUCCESS="${GREEN}[SUCCESS]${NC}"
WARN="${BLUE}[WARN]${NC}"

# Create backup directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/tmp/sources_backup_$TIMESTAMP"

convert_deb822() {
    local file="$1"
    local new_file="${file%.sources}.list"
    # If input is already .list, don't change the name
    [[ "$file" == *.list ]] && new_file="$file"
    local temp_file="${new_file}.tmp"
    local types="" uris="" suites="" components=""
    
    > "$temp_file"
    
    # Preserve comments
    sed -n '/^#/p' "$file" > "$temp_file"
    echo "" >> "$temp_file"
    
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        
        case "$line" in
            Types:*)      types=$(echo "${line#Types: }" | xargs) ;;
            URIs:*)       uris=$(echo "${line#URIs: }" | xargs) ;;
            Suites:*)     suites=$(echo "${line#Suites: }" | xargs) ;;
            Components:*) 
                components=$(echo "${line#Components: }" | xargs)
                for type in $types; do
                    case "$type" in
                        "deb"|"deb-src") ;;
                        *) 
                            echo -e "$ERROR Invalid type: $type in file $file"
                            rm "$temp_file"
                            return 1
                            ;;
                    esac
                    
                    for uri in $uris; do
                        uri=${uri%/}
                        for suite in $suites; do
                            echo "$type $uri $suite $components" >> "$temp_file"
                        done
                    done
                done
                types="" uris="" suites="" components=""
                ;;
            Signed-By:*) continue ;;
        esac
    done < "$file"
    
    if [ -s "$temp_file" ]; then
        mv "$temp_file" "$new_file"
        [[ "$file" != "$new_file" ]] && rm "$file"
        return 0
    else
        rm "$temp_file"
        return 1
    fi
}

check_format() {
    local file="$1"
    # Check if file is in Deb822 format
    if grep -q "^Types:" "$file"; then
        return 0  # File needs conversion
    fi
    return 1     # File is in correct format
}

process_file() {
    local file="$1"
    
    echo -e "$INFO Processing: $file"
    
    # Create backup
    mkdir -p "$BACKUP_DIR/$(dirname "${file#/}")"
    cp -p "$file" "$BACKUP_DIR/${file#/}" || {
        echo -e "$ERROR Failed to backup $file"
        return 1
    }
    
    # Skip empty files
    if ! grep -v '^[[:space:]]*#' "$file" | grep -q "[[:alnum:]]"; then
        echo -e "$WARN File contains only comments: $file"
        return 0
    fi
    
    # Check format and convert if necessary
    if check_format "$file"; then
        echo -e "$INFO Converting Deb822 format: $file"
        if convert_deb822 "$file"; then
            echo -e "$SUCCESS Converted: $file"
        else
            echo -e "$ERROR Failed to convert $file"
            return 1
        fi
    else
        echo -e "$INFO File already in correct format: $file"
    fi
}

# Main execution
echo -e "$INFO Starting conversion process..."

# Create backup directory
mkdir -p "$BACKUP_DIR" || {
    echo -e "$ERROR Failed to create backup directory"
    exit 1
}

errors=0

# Process both .sources and .list files
if [[ -d "/etc/apt/sources.list.d" ]]; then
    while IFS= read -r -d '' file; do
        process_file "$file" || ((errors++))
    done < <(find /etc/apt/sources.list.d -type f \( -name "*.sources" -o -name "*.list" \) -print0)
    
    # Also check the main sources.list file if it exists
    if [[ -f "/etc/apt/sources.list" ]]; then
        process_file "/etc/apt/sources.list" || ((errors++))
    fi
fi

echo
if [ $errors -eq 0 ]; then
    echo -e "$SUCCESS All files processed successfully!"
else
    echo -e "$ERROR Completed with $errors error(s)"
fi

echo -e "$INFO Backup location: $BACKUP_DIR"
echo -e "$INFO To restore: cp -r $BACKUP_DIR/* /"
echo -e "$INFO To verify changes: sudo apt update"
