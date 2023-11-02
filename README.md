# tp-env-linux

Projet de linux

## Installer MariaDB

```bash
$ sudo apt install mariadb-server -y
$ sudo systemctl start mariadb && sudo systemctl enable mariadb
$ sudo systemctl status mariadb #Pour vérifier l'installation de mariadb
$ sudo mariadb #Pour démarrer mariadb
```

## Installer et configurer Apache & PHP

```bash
# Pour installer Apache
$ sudo apt install apache2 -y
$ sudo systemctl enable apache2 && sudo systemctl start apache2
$ sudo systemctl status apache2
"""
root@host:~# sudo systemctl status apache2
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; preset: enabled)
     Active: active (running) since Thu 2023-08-03 06:02:42 CDT; 22h ago
       Docs: https://httpd.apache.org/docs/2.4/
   Main PID: 711 (apache2)
      Tasks: 10 (limit: 4644)
     Memory: 29.7M
        CPU: 4.878s
     CGroup: /system.slice/apache2.service
"""
# Pour installer PHP et ses dépendances
$ sudo apt-get install php8.2 php8.2-cli php8.2-common php8.2-imap php8.2-redis php8.2-snmp php8.2-xml php8.2-mysqli php8.2-zip php8.2-mbstring php8.2-curl libapache2-mod-php -y
$ php -v
"""
Created directory: /var/lib/snmp/cert_indexes
PHP 8.2.7 (cli) (built: Jun  9 2023 19:37:27) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.2.7, Copyright (c) Zend Technologies
    with Zend OPcache v8.2.7, Copyright (c), by Zend Technologies
# Pour installer PHP
$ sudo apt install php
"""
```

## Créer une BDD Wordpress et un utilisateur

```sql
 CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'YourStrongPasswordHere';
 CREATE DATABASE wordpress;
 GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';
 FLUSH PRIVILEGES;
 EXIT;
```

## Installer Wordpress

```bash
# Téléchargement de wordpress
$ cd var/www/html
$ wget https://wordpress.org/latest.zip
$ unzip latest.zip
$ rm latest.zip
# Permissions
$ chown -R www-data:www-data wordpress/
$ cd wordpress/
$ find . -type d -exec chmod 755 {} \;
$ find . -type f -exec chmod 644 {} \;
$ mv wp-config-sample.php wp-config.php
$ nano wp-config.php
```

## Création du fichier hôte Apache
```bash
$ cd etc/apache2/sites-available 
$ touch wordpress.conf
"""
#Ajouter ça dans le fichier
<VirtualHost *:80>
ServerName yourdomain.com
DocumentRoot /var/www/html/wordpress

<Directory /var/www/html/wordpress>
AllowOverride All
</Directory>

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

"""
$ sudo a2enmod rewrite
$ sudo a2ensite wordpress.conf
$ systemctl reload apache2
```
