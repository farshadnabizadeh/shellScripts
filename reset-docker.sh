#!/bin/bash

# Warning prompt
echo "⚠️  DANGER ZONE: This will delete ALL Docker data (Containers, Images, Volumes, Networks)."
echo "⚠️  This action is IRREVERSIBLE."
read -p "Are you absolutely sure? (Type 'y' to continue): " -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

echo "------------------------------------------------"
echo "🛑 Stopping all running containers..."
# Try to stop containers, ignore errors if no containers exist
docker stop $(docker ps -a -q) 2>/dev/null

echo "🗑️  Removing all containers..."
docker rm -f $(docker ps -a -q) 2>/dev/null

echo "🖼️  Removing all images..."
docker rmi -f $(docker images -q) 2>/dev/null

echo "💾 Removing all volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null

echo "🌐 Removing all networks..."
docker network prune -f 2>/dev/null

echo "🧹 Performing deep system prune (caches & leftovers)..."
docker system prune -a --volumes -f

echo "------------------------------------------------"
echo "✅ Docker has been completely reset to factory state."
