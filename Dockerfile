FROM wordpress:php8.2-apache

RUN curl -sL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp \
    && wp --info --allow-root 2>/dev/null || true

RUN cat > /usr/local/bin/fix-wordpress.sh << 'SCRIPTEOF'
#!/bin/sh
HTACCESS="/var/www/html/.htaccess"
MUDIR="/var/www/html/wp-content/mu-plugins"
MUPLUGIN="$MUDIR/fix-htaccess.php"

write_clean_htaccess() {
    printf 'Options +FollowSymLinks\n# BEGIN WordPress\n<IfModule mod_rewrite.c>\nRewriteEngine On\nRewriteBase /\nRewriteRule ^index\\.php$ - [L]\nRewriteCond %%{REQUEST_FILENAME} !-f\nRewriteCond %%{REQUEST_FILENAME} !-d\nRewriteRule . /index.php [L]\n</IfModule>\n# END WordPress\n' > "$HTACCESS"
    echo "=== fix-wordpress: .htaccess reset ===" >&2
}
htaccess_blocked() {
    grep -qiE '<Files[^>]*\.php|Deny from all|Require all denied' "$HTACCESS" 2>/dev/null
}

echo "=== fix-wordpress: restoring core WP files ===" >&2
if [ -d "/usr/src/wordpress" ]; then
    for f in /usr/src/wordpress/*.php; do fname=$(basename "$f"); cp -f "$f" "/var/www/html/$fname" 2>/dev/null; done
    cp -rf /usr/src/wordpress/wp-includes /var/www/html/ 2>/dev/null
    cp -rf /usr/src/wordpress/wp-admin /var/www/html/ 2>/dev/null
fi

echo "=== fix-wordpress: scanning plugins for malware ===" >&2
PLUGINS_DIR="/var/www/html/wp-content/plugins"
if [ -d "$PLUGINS_DIR" ]; then
    find "$PLUGINS_DIR" -name "*.php" | while read f; do
        if grep -qE 'yrxc_uck|FilesMan|r57shell|c99shell|eval\(base64_decode|eval\(gzinflate|eval\(str_rot13' "$f" 2>/dev/null; then
            rm -f "$f"
        fi
    done
fi

WPCONFIG="/var/www/html/wp-config.php"
if [ -f "$WPCONFIG" ] && ! grep -q 'WP_DEBUG_LOG' "$WPCONFIG"; then
    sed -i "s|define( 'DB_NAME'|define('WP_DEBUG', true);\ndefine('WP_DEBUG_LOG', true);\ndefine('WP_DEBUG_DISPLAY', false);\ndefine( 'DB_NAME'|" "$WPCONFIG"
fi

mkdir -p "$MUDIR"
cat > "$MUPLUGIN" << 'MUEOF'
<?php
add_filter('mod_rewrite_rules', function($rules) {
    if (strpos($rules, 'FollowSymLinks') === false) { $rules = "Options +FollowSymLinks\n" . $rules; }
    return $rules;
}, 1);
MUEOF

THEMES_DIR="/var/www/html/wp-content/themes"
if [ ! -d "$THEMES_DIR/ashe" ] && [ -d "/usr/local/ashe-theme" ]; then
    cp -r /usr/local/ashe-theme "$THEMES_DIR/ashe"
    chown -R www-data:www-data "$THEMES_DIR/ashe"
fi

if htaccess_blocked; then
    write_clean_htaccess
elif ! grep -q 'FollowSymLinks' "$HTACCESS" 2>/dev/null; then
    printf 'Options +FollowSymLinks\n' > /tmp/htfix
    cat "$HTACCESS" >> /tmp/htfix 2>/dev/null
    mv /tmp/htfix "$HTACCESS"
fi

WP_PATH="/var/www/html"
if command -v wp >/dev/null 2>&1 && [ -f "$WP_PATH/wp-config.php" ]; then
    wp user update maxlau --user_pass='admin123' --allow-root --path="$WP_PATH" 2>/dev/null || true
    CURRENT_THEME=$(wp option get template --allow-root --path="$WP_PATH" 2>/dev/null)
    if [ "$CURRENT_THEME" != "maxlau-seth" ] && [ -d "$THEMES_DIR/maxlau-seth" ]; then
        wp theme activate maxlau-seth --allow-root --path="$WP_PATH" 2>/dev/null || true
        echo "=== fix-wordpress: maxlau-seth theme activated ===" >&2
    fi
fi

echo "=== fix-wordpress: startup done ===" >&2
(while true; do sleep 5; if htaccess_blocked; then write_clean_htaccess; fi; done) &
SCRIPTEOF
RUN chmod +x /usr/local/bin/fix-wordpress.sh

RUN { head -1 /usr/local/bin/apache2-foreground; \
    echo 'rm -f /etc/apache2/mods-enabled/mpm_event.conf /etc/apache2/mods-enabled/mpm_event.load'; \
    echo 'rm -f /etc/apache2/mods-enabled/mpm_worker.conf /etc/apache2/mods-enabled/mpm_worker.load'; \
    echo 'rm -f /etc/apache2/mods-enabled/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.load'; \
    echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf'; \
    echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load'; \
    echo '/usr/local/bin/fix-wordpress.sh'; \
    tail -n +2 /usr/local/bin/apache2-foreground; \
} > /tmp/apache2-foreground \
    && mv /tmp/apache2-foreground /usr/local/bin/apache2-foreground \
    && chmod +x /usr/local/bin/apache2-foreground

RUN printf '<Directory /var/www/html>\n    Options +FollowSymLinks\n</Directory>\n' \
    > /etc/apache2/conf-available/wp-followsymlinks.conf \
    && a2enconf wp-followsymlinks

COPY wp-content/themes/ashe /usr/local/ashe-theme/
COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
