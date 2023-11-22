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

WEBPACKAGE="dpkg -s apache2 php8.2 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        sudo apt-get install apache2 -y &&
        echo 'apache2 installé' &&
        sudo systemctl enable apache2 &&
        sudo systemctl start apache2 &&
        sudo systemctl --no-pager status apache2
        echo 'apache2 status' &&
        sudo apt-get install php8.2 php8.2-cli php8.2-common php8.2-imap php8.2-redis php8.2-snmp php8.2-xml php8.2-mysqli php8.2-zip php8.2-mbstring php8.2-curl libapache2-mod-php php-mysql -y &&
        echo 'php installé' &&
        php -v
    else
        echo 'apache2 et php8.2 sont déjà installés'
    fi"

BDDPACKAGE="dpkg -s mariadb-server > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        sudo apt-get install mariadb-server -y &&
        sudo systemctl enable mariadb &&
        sudo systemctl start mariadb &&
        sudo systemctl --no-pager status mariadb
    else
        echo 'mariadb-server est déjà installé'
    fi"

DBNAME="test"
DBUSER="hugo"
DBPASSWD="epsi"

BDDCONFIG=$(printf "sudo mysql -uroot -e '
CREATE DATABASE IF NOT EXISTS %s;
CREATE USER %s@'localhost' IDENTIFIED BY '%s';
GRANT ALL PRIVILEGES ON %s.* TO %s@'localhost';
FLUSH PRIVILEGES;'" $DBNAME $DBUSER $DBPASSWD $DBNAME $DBUSER)

CHECKDB=$(printf "sudo mysql -uroot -e 'SHOW DATABASES LIKE \"%s\"'" $DBNAME)
CHECKUSER=$(printf "sudo mysql -uroot -e 'SELECT User FROM mysql.user WHERE User=\"%s\"'" $DBUSER)

# Boucle pour parcourir toutes les lignes du fichier csv avec la commande ssh
for i in $(cat $CSV_FILE | cut -d ',' -f 1); do
    if [ $i == "web" ]; then
        command_ssh $i "$WEBPACKAGE"
    elif [ $i == "bdd" ]; then
        command_ssh $i "$BDDPACKAGE && $BDDCONFIG && $CHECKDB && $CHECKUSER"
    else
        echo "$i n'est pas un nom valide"
    fi
done