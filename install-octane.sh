#!/bin/bash

# Stop on first error
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "${YELLOW}    Laravel Octane (FrankenPHP) Automated Installer for WSL  ${NC}"
echo -e "${YELLOW}-------------------------------------------------------------${NC}"

# 1. Get Project Name
read -p "Enter your new project name (e.g., my-app): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Project name is required.${NC}"
    exit 1
fi

if [ -d "$PROJECT_NAME" ]; then
    echo -e "${RED}Directory $PROJECT_NAME already exists. Please choose another name or delete it.${NC}"
    exit 1
fi

echo -e "${GREEN}==> Step 1: Creating Laravel project '${PROJECT_NAME}'...${NC}"

# Create Project
curl -s "https://laravel.build/$PROJECT_NAME" | bash

echo -e "${GREEN}==> Step 2: Starting Sail Containers...${NC}"
# Enter the directory
cd "$PROJECT_NAME"

# Check if docker-compose.yml exists right after creation
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Error: docker-compose.yml not found after installation!${NC}"
    exit 1
fi

./vendor/bin/sail up -d

echo -e "${GREEN}==> Step 3: Installing Laravel Octane...${NC}"
./vendor/bin/sail composer require laravel/octane

echo -e "${GREEN}==> Step 4: Installing FrankenPHP Server...${NC}"
# Auto-confirm with yes
yes | ./vendor/bin/sail artisan octane:install --server=frankenphp

echo -e "${GREEN}==> Step 5: Installing NPM dependencies & Chokidar...${NC}"
./vendor/bin/sail npm install
./vendor/bin/sail npm install --save-dev chokidar

echo -e "${GREEN}==> Step 6: Configuring docker-compose.yml for Octane...${NC}"

# Define the search string and the string to insert
SEARCH_STRING="WWWGROUP: '\${WWWGROUP}'"
# Note the indentation here is critical for YAML
INSERT_STRING="            SUPERVISOR_PHP_COMMAND: \"/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=frankenphp --host=0.0.0.0 --admin-port=2019 --port='\${APP_PORT:-80}' --watch\""

# Check if file exists again just to be safe
if [ -f "docker-compose.yml" ]; then
    # Use perl for more robust regex handling than sed, specifically for newlines/indentation
    # This replaces the line containing WWWGROUP with itself + a newline + the new command
    perl -i -pe "s|($SEARCH_STRING)|$SEARCH_STRING\n$INSERT_STRING|" docker-compose.yml
    
    echo -e "${GREEN}==> Configuration injected successfully.${NC}"
else
    echo -e "${RED}Error: docker-compose.yml not found in $(pwd)${NC}"
    exit 1
fi

echo -e "${GREEN}==> Step 7: Restarting Sail to apply changes...${NC}"
./vendor/bin/sail down
./vendor/bin/sail up -d

echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "${GREEN}   INSTALLATION COMPLETE!   ${NC}"
echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "You can now access your site at: http://localhost"
echo -e "To see logs, run: cd $PROJECT_NAME && ./vendor/bin/sail logs -f"
echo -e "Enjoy high-speed Laravel Octane! 🚀"
