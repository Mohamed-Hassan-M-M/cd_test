#!/bin/bash

APP_NAME="cd_test"
DEPLOY_DIR="/var/www/$APP_NAME"
PHP_VERSION="8.2"

# Check if previous_release file exists
if [ ! -f "$DEPLOY_DIR/previous_release" ]; then
  echo "❌ No previous release to roll back to."
  exit 1
fi

# Read previous release path
PREV_RELEASE=$(cat $DEPLOY_DIR/previous_release)

if [ ! -d "$PREV_RELEASE" ]; then
  echo "❌ Previous release directory not found: $PREV_RELEASE"
  exit 1
fi

# Roll back symlink
echo "🔁 Rolling back to: $PREV_RELEASE"
ln -nfs $PREV_RELEASE $DEPLOY_DIR/current

# Reload services
echo "🔄 Restarting services..."
systemctl reload apache2
supervisorctl restart ${APP_NAME}_queue:*
supervisorctl restart ${APP_NAME}_websockets

echo "✅ Rollback complete."
