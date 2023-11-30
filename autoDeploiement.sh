#!/bin/bash

# Fichier CSV contenant les informations de connexion
CSV_FILE="/c/Users/Hugo/Desktop/Bash/tp-env-linux/ip.csv"

# Demander le mot de passe sudoers une seule fois au lieu de le faire à chaque tour de boucle
OLDMODE=$(stty -g)
stty -echo
read -p "sudoers password: " SUDOPASS
stty $OLDMODE

function command_ssh {
    [ $# -gt 0 ] || return 1

    local CSV_FILE="/c/Users/Hugo/Desktop/Bash/tp-env-linux/ip.csv"
    local target_name="$1"

    # Recherche de l'adresse IP dans le fichier CSV en fonction du nom
    for target_ip in $(grep $target_name $CSV_FILE | cut -d',' -f2)
    do
        if [ -n "$target_ip" ]; then
            # Connexion SSH en utilisant l'adresse IP trouvée
            echo "$SUDOPASS" | ssh -tt $target_name@"$target_ip" "$2"
        else
            echo "Nom non trouvé dans le fichier CSV : $target_name"
            return 1
        fi
    done
}

WEBPACKAGE="
        function is_package_installed {
            dpkg -s \"\$1\" &> /dev/null
            if [ \$? -eq 0 ]; then
                return 0
            else
                return 1
            fi
        }

        function install_package {
            if is_package_installed \"\$1\"; then
                echo \"\$1 est déjà installé\"
            else
                sudo apt-get install -y \"\$1\"
                echo \"\$1 installé\"
            fi
        }

        install_package apache2 &&
        sudo systemctl enable apache2 &&
        sudo systemctl start apache2 &&
        sudo systemctl --no-pager -l status apache2
        echo 'apache2 status' &&
        install_package php8.2 php8.2-cli php8.2-common php8.2-imap php8.2-redis php8.2-snmp php8.2-xml php8.2-mysqli php8.2-zip php8.2-mbstring php8.2-curl libapache2-mod-php php-mysql &&
        echo 'php installé' &&
        php -v &&
        if [ ! -d /var/www/html/wordpress ]; then
            wget https://wordpress.org/latest.tar.gz &&
            tar xzvf latest.tar.gz &&
            sudo mv wordpress /var/www/html/ &&
            sudo chown -R www-data:www-data /var/www/html/wordpress
        else
            echo 'WordPress est déjà installé'
        fi"

BDDPACKAGE="
        function is_package_installed {
            dpkg -s \"\$1\" &> /dev/null
            if [ \$? -eq 0 ]; then
                return 0
            else
                return 1
            fi
        }

        function install_package {
            if is_package_installed \"\$1\"; then
                echo \"\$1 est déjà installé\"
            else
                sudo apt-get install -y \"\$1\"
                echo \"\$1 installé\"
            fi
        }

        install_package mariadb-server &&
        sudo systemctl enable mariadb &&
        sudo systemctl start mariadb &&
        sudo systemctl --no-pager -l status mariadb &&
        if [ \$(sudo mysql -uroot -e 'SHOW DATABASES LIKE \"$DBNAME\"' | wc -l) -eq 0 ]; then
            sudo mysql -uroot -e '
            CREATE DATABASE IF NOT EXISTS $DBNAME;
            CREATE USER IF NOT EXISTS $DBUSER@'localhost' IDENTIFIED BY \"$DBPASSWD\";
            GRANT ALL PRIVILEGES ON $DBNAME.* TO $DBUSER@'localhost';
            FLUSH PRIVILEGES;'
        else
            echo 'La base de données est déjà configurée'
        fi"

# Commandes pour configurer la base de données
DBNAME="test"
DBUSER="hugo"
DBPASSWD="epsi"

BDDCONFIG=$(printf "sudo mysql -uroot -e '
CREATE DATABASE IF NOT EXISTS %s;
CREATE USER %s@'localhost' IDENTIFIED BY \"%s\";
GRANT ALL PRIVILEGES ON %s.* TO %s@'localhost';
FLUSH PRIVILEGES;'" $DBNAME $DBUSER $DBPASSWD $DBNAME $DBUSER)

CHECKDB=$(printf "sudo mysql -uroot -e 'SHOW DATABASES LIKE \"%s\"'" $DBNAME)
CHECKUSER=$(printf "sudo mysql -uroot -e 'SELECT User FROM mysql.user WHERE User=\"%s\"'" $DBUSER)

# Commandes pour vérifier que tout est installé sur la vm web
CHECKINSTALLWEB="
        sudo systemctl --no-pager -l status apache2 &&
        php -v &&
        ls wordpress"

# Commandes pour vérifier que tout est installé sur la vm bdd
CHECKINSTALLBDD="
        sudo systemctl --no-pager -l status mariadb &&
        $CHECKDB &&
        $CHECKUSER"

# Boucle pour parcourir toutes les lignes du fichier csv avec la commande ssh
for i in $(cat $CSV_FILE | cut -d ',' -f 1); do
    if [ $i == "web" ]; then
        command_ssh $i "$WEBPACKAGE && $CHECKINSTALLWEB"
    elif [ $i == "bdd" ]; then
        command_ssh $i "$BDDPACKAGE && $BDDCONFIG && $CHECKINSTALLBDD"
    else
        echo "$i n'est pas un nom valide"
    fi
done
