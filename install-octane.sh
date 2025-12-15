#!/bin/bash

# Stop on first error
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if user is in /mnt (Windows filesystem)
if [[ "$PWD" == /mnt/* ]]; then
    echo -e "${RED}WARNING: You are running this script inside a Windows mounted directory ($PWD).${NC}"
    echo -e "${YELLOW}This causes massive performance issues and installation failures with Docker.${NC}"
    echo -e "${YELLOW}Please move to your Linux home directory by running: cd ~${NC}"
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

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
    echo -e "${RED}Directory '$PROJECT_NAME' already exists. Please delete it first.${NC}"
    exit 1
fi

echo -e "${GREEN}==> Step 1: Creating Laravel project '${PROJECT_NAME}'...${NC}"

# Create Project
curl -s "https://laravel.build/$PROJECT_NAME" | bash

echo -e "${GREEN}==> Step 2: Verifying Installation...${NC}"

# Check if directory exists
if [ ! -d "$PROJECT_NAME" ]; then
     echo -e "${RED}CRITICAL ERROR: The directory '$PROJECT_NAME' was not created.${NC}"
     echo -e "Did Laravel installer output 'cd app'? If so, the installer ignored your project name."
     echo -e "Current directory content:"
     ls -la
     exit 1
fi

cd "$PROJECT_NAME"

# DEBUG: Check contents
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}CRITICAL ERROR: docker-compose.yml not found!${NC}"
    echo -e "${YELLOW}Installation seems incomplete. Here are the files that WERE created:${NC}"
    ls -la
    echo -e "${YELLOW}------------------------------------------------${NC}"
    echo -e "${YELLOW}If the folder is empty or misses files, Docker failed to write to your disk.${NC}"
    exit 1
fi

echo -e "${GREEN}==> Step 3: Starting Sail Containers...${NC}"
./vendor/bin/sail up -d

echo -e "${GREEN}==> Step 4: Installing Laravel Octane...${NC}"
./vendor/bin/sail composer require laravel/octane

echo -e "${GREEN}==> Step 5: Installing FrankenPHP Server...${NC}"
yes | ./vendor/bin/sail artisan octane:install --server=frankenphp

echo -e "${GREEN}==> Step 6: Installing NPM dependencies & Chokidar...${NC}"
./vendor/bin/sail npm install
./vendor/bin/sail npm install --save-dev chokidar

echo -e "${GREEN}==> Step 7: Configuring docker-compose.yml for Octane...${NC}"

SEARCH_STRING="WWWGROUP: '\${WWWGROUP}'"
INSERT_STRING="            SUPERVISOR_PHP_COMMAND: \"/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=frankenphp --host=0.0.0.0 --admin-port=2019 --port='\${APP_PORT:-80}' --watch\""

# Use Perl for safe replacement
perl -i -pe "s|($SEARCH_STRING)|$SEARCH_STRING\n$INSERT_STRING|" docker-compose.yml

echo -e "${GREEN}==> Step 8: Restarting Sail...${NC}"
./vendor/bin/sail down
./vendor/bin/sail up -d

echo -e "${GREEN}   INSTALLATION COMPLETE!   ${NC}"
echo -e "Access at: http://localhost"

### چک‌لیست نهایی (مهم)
1.  **Docker Desktop:** مطمئن شوید Docker Desktop در ویندوز باز است و در تنظیمات آن (Settings -> Resources -> WSL Integration)، تیکِ توزیع لینوکس شما (مثلاً Ubuntu) خورده باشد.
2.  **اینترنت:** نصب اولیه نیاز به دانلود حدود ۵۰۰ مگابایت دیتا دارد. اگر VPN دارید، مطمئن شوید که در WSL هم فعال است (معمولاً با حالت Tun Mode یا تنظیمات پروکسی).