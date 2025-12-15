#!/bin/bash

# Stop on first error
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "${YELLOW}    Laravel Octane (FrankenPHP) Installer (WSL Compatible)   ${NC}"
echo -e "${YELLOW}-------------------------------------------------------------${NC}"

# 1. Get Project Name
read -p "Enter your new project name (e.g., my-app): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Project name is required.${NC}"
    exit 1
fi

if [ -d "$PROJECT_NAME" ]; then
    echo -e "${RED}Directory '$PROJECT_NAME' already exists. Please delete it or choose another name.${NC}"
    exit 1
fi

echo -e "${GREEN}==> Step 1: Creating Laravel project '${PROJECT_NAME}'...${NC}"
curl -s "https://laravel.build/$PROJECT_NAME" | bash

echo -e "${GREEN}==> Step 2: Entering Project Directory...${NC}"
cd "$PROJECT_NAME"

# --- SMART DETECTION FOR DOCKER FILE ---
DOCKER_FILE=""
if [ -f "compose.yaml" ]; then
    DOCKER_FILE="compose.yaml"
    echo -e "${GREEN}Detected modern Docker file: compose.yaml${NC}"
elif [ -f "docker-compose.yml" ]; then
    DOCKER_FILE="docker-compose.yml"
    echo -e "${GREEN}Detected legacy Docker file: docker-compose.yml${NC}"
else
    echo -e "${RED}CRITICAL ERROR: Neither 'compose.yaml' nor 'docker-compose.yml' found!${NC}"
    ls -la
    exit 1
fi
# ---------------------------------------

echo -e "${GREEN}==> Step 3: Starting Sail Containers...${NC}"
./vendor/bin/sail up -d

echo -e "${GREEN}==> Step 4: Installing Laravel Octane...${NC}"
./vendor/bin/sail composer require laravel/octane

echo -e "${GREEN}==> Step 5: Installing FrankenPHP Server...${NC}"
yes | ./vendor/bin/sail artisan octane:install --server=frankenphp

echo -e "${GREEN}==> Step 6: Installing NPM & Chokidar...${NC}"
./vendor/bin/sail npm install
./vendor/bin/sail npm install --save-dev chokidar

echo -e "${GREEN}==> Step 7: Configuring $DOCKER_FILE for Octane...${NC}"

SEARCH_STRING="WWWGROUP: '\${WWWGROUP}'"
INSERT_STRING="            SUPERVISOR_PHP_COMMAND: \"/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=frankenphp --host=0.0.0.0 --admin-port=2019 --port='\${APP_PORT:-80}' --watch\""

# Inject into the detected file
perl -i -pe "s|($SEARCH_STRING)|$SEARCH_STRING\n$INSERT_STRING|" "$DOCKER_FILE"

echo -e "${GREEN}==> Step 8: Restarting Sail to apply changes...${NC}"
./vendor/bin/sail down
./vendor/bin/sail up -d

echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "${GREEN}   INSTALLATION COMPLETE!   ${NC}"
echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "Access your app at: http://localhost"
echo -e "To watch logs: cd $PROJECT_NAME && ./vendor/bin/sail logs -f"
