#!/bin/bash

set -e

APP_NAME="myapp"
DEPLOY_DIR="/var/www/$APP_NAME"
GITHUB_REPO="git@github.com:Mohamed-Hassan-M-M/cd_test.git"   # Change this
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
RELEASE_DIR="$DEPLOY_DIR/releases/$TIMESTAMP"
PHP_VERSION="8.2"
DB_BACKUP_DIR="$DEPLOY_DIR/db_backups"
BACKUP_FILE="$DB_BACKUP_DIR/backup_$TIMESTAMP.sql"
DOMAIN_NAME="192.168.7.181"   # Change this to your real domain

echo "🚀 Starting deployment of $APP_NAME at $TIMESTAMP..."

# 1. Create DB Backup
echo "🧩 Backing up database..."
mkdir -p "$DB_BACKUP_DIR"
mysqldump -u root -pYOUR_DB_PASSWORD YOUR_DB_NAME > "$BACKUP_FILE"
echo "✅ Database backup saved to $BACKUP_FILE"

# 2. Clone the latest code
echo "📦 Cloning repository..."
git clone $GITHUB_REPO $RELEASE_DIR

# 3. Move into release dir and install dependencies
cd $RELEASE_DIR
echo "📦 Installing composer dependencies..."
composer install --no-dev --optimize-autoloader

# 4. Copy Firebase service-account.json to shared storage
echo "🔐 Copying Firebase service account..."
cp storage/app/public/service-account.json $DEPLOY_DIR/shared/storage/app/public/service-account.json

# 5. Use .env.production as the live .env
echo "🔧 Setting environment..."
cp $RELEASE_DIR/.env.production $DEPLOY_DIR/shared/.env

# 6. Link shared files/directories
echo "🔗 Linking shared directories..."
ln -nfs $DEPLOY_DIR/shared/.env $RELEASE_DIR/.env
rm -rf storage
ln -nfs $DEPLOY_DIR/shared/storage $RELEASE_DIR/storage
ln -nfs $DEPLOY_DIR/shared/bootstrap/cache $RELEASE_DIR/bootstrap/cache

# 7. Laravel pre-boot cache
echo "🧪 Caching config, routes, views..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 8. Run migrations
echo "📂 Running database migrations..."
php artisan migrate --force

# 9. Set proper permissions
echo "🔒 Fixing permissions..."
chown -R www-data:www-data $RELEASE_DIR

# 10. Update current symlink and save the prev for rollback
echo "🔁 Saving current release path as previous and Updating current symlink to the new release..."
if [ -L "$DEPLOY_DIR/current" ]; then
  readlink $DEPLOY_DIR/current > $DEPLOY_DIR/previous_release
fi
ln -nfs $RELEASE_DIR $DEPLOY_DIR/current

# 11. Restart services
echo "🔄 Reloading services..."
systemctl reload apache2
supervisorctl restart ${APP_NAME}_queue:*
supervisorctl restart ${APP_NAME}_websockets

echo "🎉 Deployment complete!"
echo "🌍 Visit: https://$DOMAIN_NAME"
