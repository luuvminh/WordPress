FROM wordpress:php8.2-apache

# Create the persistent-fix startup script at build time
RUN cat > /usr/local/bin/fix-wordpress.sh << 'SCRIPTEOF'
#!/bin/sh
HTACCESS="/var/www/html/.htaccess"
MUDIR="/var/www/html/wp-content/mu-plugins"
MUPLUGIN="$MUDIR/fix-htaccess.php"

# Write clean WordPress .htaccess (no PHP-blocking rules)
write_clean_htaccess() {
    printf 'Options +FollowSymLinks\n# BEGIN WordPress\n<IfModule mod_rewrite.c>\nRewriteEngine On\nRewriteBase /\nRewriteRule ^index\\.php$ - [L]\nRewriteCond %%{REQUEST_FILENAME} !-f\nRewriteCond %%{REQUEST_FILENAME} !-d\nRewriteRule . /index.php [L]\n</IfModule>\n# END WordPress\n' > "$HTACCESS"
    echo "=== fix-wordpress: .htaccess reset to clean standard ===" >&2
}
# Check if .htaccess contains PHP-blocking rules from security plugins
htaccess_blocked() {
    grep -qiE '<Files[^>]*\.php|Deny from all|Require all denied' "$HTACCESS" 2>/dev/null
}

# === SECURITY: Restore core WordPress files from the clean Docker image source ===
echo "=== fix-wordpress: restoring core WP files from clean image ===" >&2
if [ -d "/usr/src/wordpress" ]; then
    for f in /usr/src/wordpress/*.php; do
        fname=$(basename "$f")
        cp -f "$f" "/var/www/html/$fname" 2>/dev/null
    done
    cp -rf /usr/src/wordpress/wp-includes /var/www/html/ 2>/dev/null
    cp -rf /usr/src/wordpress/wp-admin /var/www/html/ 2>/dev/null
    echo "=== fix-wordpress: core files restored ===" >&2
fi

# === SECURITY: Remove plugin files with known malware signatures ===
echo "=== fix-wordpress: scanning plugins for malware ===" >&2
PLUGINS_DIR="/var/www/html/wp-content/plugins"
if [ -d "$PLUGINS_DIR" ]; then
    find "$PLUGINS_DIR" -name "*.php" | while read f; do
        if grep -qE 'yrxc_uck|FilesMan|r57shell|c99shell|eval\(base64_decode|eval\(gzinflate|eval\(str_rot13' "$f" 2>/dev/null; then
            echo "=== fix-wordpress: MALWARE removed: $f ===" >&2
            rm -f "$f"
        fi
    done
fi

# === DEBUG: Enable WP_DEBUG_LOG so errors are written to wp-content/debug.log ===
WPCONFIG="/var/www/html/wp-config.php"
if [ -f "$WPCONFIG" ] && ! grep -q 'WP_DEBUG_LOG' "$WPCONFIG"; then
    sed -i "s|define( 'DB_NAME'|define('WP_DEBUG', true);\ndefine('WP_DEBUG_LOG', true);\ndefine('WP_DEBUG_DISPLAY', false);\ndefine( 'DB_NAME'|" "$WPCONFIG"
    echo "=== fix-wordpress: WP_DEBUG_LOG enabled ===" >&2
fi

# Deploy mu-plugin so WordPress always prepends FollowSymLinks on .htaccess regeneration
mkdir -p "$MUDIR"
cat > "$MUPLUGIN" << 'MUEOF'
<?php
/** Plugin Name: Fix .htaccess for Docker */
add_filter('mod_rewrite_rules', function($rules) {
    if (strpos($rules, 'FollowSymLinks') === false) {
        $rules = "Options +FollowSymLinks\n" . $rules;
    }
    return $rules;
}, 1);
MUEOF

# === INSTALL: Restore Ashe theme if missing after container rebuild ===
THEMES_DIR="/var/www/html/wp-content/themes"
if [ ! -d "$THEMES_DIR/ashe" ]; then
    echo "=== fix-wordpress: Ashe theme missing - downloading from WordPress.org ===" >&2
        curl -sL -o /tmp/ashe.zip "https://downloads.wordpress.org/theme/ashe.latest-stable.zip" 2>/dev/null
            if [ -f /tmp/ashe.zip ] && [ -s /tmp/ashe.zip ]; then
                    unzip -q /tmp/ashe.zip -d "$THEMES_DIR/" 2>/dev/null
                            chown -R www-data:www-data "$THEMES_DIR/ashe" 2>/dev/null
                                    rm -f /tmp/ashe.zip
                                            echo "=== fix-wordpress: Ashe theme installed ===" >&2
                                                else
                                                        echo "=== fix-wordpress: WARNING - Ashe download failed ===" >&2
                                                                rm -f /tmp/ashe.zip
                                                                    fi
                                                                    fi
                                                                    
                                                                    # Startup fix
echo "=== fix-wordpress: startup check ===" >&2
if htaccess_blocked; then
    echo "=== fix-wordpress: PHP-blocking rules found at startup - resetting ===" >&2
    write_clean_htaccess
elif ! grep -q 'FollowSymLinks' "$HTACCESS" 2>/dev/null; then
    printf 'Options +FollowSymLinks\n' > /tmp/htfix
    cat "$HTACCESS" >> /tmp/htfix 2>/dev/null
    mv /tmp/htfix "$HTACCESS"
    echo "=== fix-wordpress: FollowSymLinks prepended ===" >&2
fi
echo "=== fix-wordpress: startup done ===" >&2

# Background watchdog: reset .htaccess if security plugin re-adds PHP-blocking rules
(
    while true; do
        sleep 5
        if htaccess_blocked; then
            echo "=== fix-wordpress: WATCHDOG detected PHP-blocking rules - resetting ===" >&2
            write_clean_htaccess
        fi
    done
) &
echo "=== fix-wordpress: watchdog started (PID $!) ===" >&2
SCRIPTEOF
RUN chmod +x /usr/local/bin/fix-wordpress.sh

# Fix MPM prefork + run fix-wordpress.sh after volume mounts on every container start
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

# Permanent fix for mod_rewrite 403: set Options +FollowSymLinks at the Apache server config level
RUN printf '<Directory /var/www/html>\n    Options +FollowSymLinks\n</Directory>\n' \
    > /etc/apache2/conf-available/wp-followsymlinks.conf \
    && a2enconf wp-followsymlinks

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
