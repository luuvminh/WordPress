FROM wordpress:php8.2-apache

# Create the persistent-fix startup script at build time
RUN cat > /usr/local/bin/fix-wordpress.sh << 'SCRIPTEOF'
#!/bin/sh
HTACCESS="/var/www/html/.htaccess"
MUDIR="/var/www/html/wp-content/mu-plugins"
MUPLUGIN="$MUDIR/fix-htaccess.php"

# Deploy mu-plugin so WordPress always prepends FollowSymLinks when regenerating .htaccess
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

# Fix .htaccess: detect and remove PHP-blocking rules written by security plugins
echo "=== fix-wordpress: checking .htaccess ===" >&2
if grep -qiE 'FilesMatch[^>]*php|<Files[^>]*php|Deny from all|Require all denied' "$HTACCESS" 2>/dev/null; then
    echo "=== PHP-blocking rules found - resetting .htaccess ===" >&2
    printf 'Options +FollowSymLinks\n# BEGIN WordPress\n<IfModule mod_rewrite.c>\nRewriteEngine On\nRewriteBase /\nRewriteRule ^index\\.php$ - [L]\nRewriteCond %%{REQUEST_FILENAME} !-f\nRewriteCond %%{REQUEST_FILENAME} !-d\nRewriteRule . /index.php [L]\n</IfModule>\n# END WordPress\n' > "$HTACCESS"
    echo "=== .htaccess reset to clean WordPress standard ===" >&2
elif ! grep -q 'FollowSymLinks' "$HTACCESS" 2>/dev/null; then
    printf 'Options +FollowSymLinks\n' > /tmp/htfix
    cat "$HTACCESS" >> /tmp/htfix 2>/dev/null
    mv /tmp/htfix "$HTACCESS"
    echo "=== FollowSymLinks prepended to .htaccess ===" >&2
fi
echo "=== fix-wordpress: done ===" >&2
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
