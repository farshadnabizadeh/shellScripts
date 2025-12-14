#!/bin/bash

# Stop on first error
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "${YELLOW}    Laravel Octane (FrankenPHP) Automated Installer for WSL  ${NC}"
echo -e "${YELLOW}-------------------------------------------------------------${NC}"

# 1. Get Project Name
read -p "Enter your new project name (e.g., my-app): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo "Project name is required."
    exit 1
fi

if [ -d "$PROJECT_NAME" ]; then
    echo "Directory $PROJECT_NAME already exists. Please choose another name or delete it."
    exit 1
fi

echo -e "${GREEN}==> Step 1: Creating Laravel project '${PROJECT_NAME}'...${NC}"
echo -e "${YELLOW}(This may take a few minutes depending on your internet connection)${NC}"

# 2. Create Project using Laravel Build
curl -s "https://laravel.build/$PROJECT_NAME" | bash

echo -e "${GREEN}==> Step 2: Starting Sail Containers...${NC}"
cd "$PROJECT_NAME"
./vendor/bin/sail up -d

echo -e "${GREEN}==> Step 3: Installing Laravel Octane...${NC}"
./vendor/bin/sail composer require laravel/octane

echo -e "${GREEN}==> Step 4: Installing FrankenPHP Server (Auto-confirming download)...${NC}"
# *** CHANGE HERE: piping 'yes' to automatically accept the binary download ***
yes | ./vendor/bin/sail artisan octane:install --server=frankenphp

echo -e "${GREEN}==> Step 5: Installing NPM dependencies & Chokidar (for --watch mode)...${NC}"
./vendor/bin/sail npm install
./vendor/bin/sail npm install --save-dev chokidar

echo -e "${GREEN}==> Step 6: Configuring docker-compose.yml for Octane...${NC}"

# Inject SUPERVISOR_PHP_COMMAND into docker-compose.yml
sed -i "/WWWGROUP: '\${WWWGROUP}'/a \\            SUPERVISOR_PHP_COMMAND: \"/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=frankenphp --host=0.0.0.0 --admin-port=2019 --port='\${APP_PORT:-80}' --watch\"" docker-compose.yml

echo -e "${GREEN}==> Configuration injected successfully.${NC}"

echo -e "${GREEN}==> Step 7: Restarting Sail to apply changes...${NC}"
./vendor/bin/sail down
./vendor/bin/sail up -d

echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "${GREEN}   INSTALLATION COMPLETE!   ${NC}"
echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "You can now access your site at: http://localhost"
echo -e "To see logs, run: cd $PROJECT_NAME && ./vendor/bin/sail logs -f"
echo -e "Enjoy high-speed Laravel Octane! 🚀"
