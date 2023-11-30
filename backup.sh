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

# Variables
DBNAME="test"
DBUSER="hugo"
DBPASSWD="epsi"
WEB_DIR="/var/www/html"
BACKUP_DIRWEB="/home/web/backup"
BACKUP_DIRBDD="/home/bdd/backup"

# Boucle pour parcourir toutes les lignes du fichier csv avec la commande ssh
for i in $(cat $CSV_FILE | cut -d ',' -f 1); do
    if [ $i == "web" ]; then
        # Crée le répertoire de sauvegarde s'il n'existe pas
        command_ssh $i "mkdir -p $BACKUP_DIRWEB"
        # Sauvegarde du site web
        command_ssh $i "tar -czf $BACKUP_DIRWEB/web_backup.tar.gz $WEB_DIR"
    elif [ $i == "bdd" ]; then
        # Crée le répertoire de sauvegarde s'il n'existe pas
        command_ssh $i "mkdir -p $BACKUP_DIRBDD"
        # Sauvegarde de la base de données
        command_ssh $i "mysqldump -u$DBUSER -p$DBPASSWD $DBNAME > $BACKUP_DIRBDD/db_backup.sql"
    else
        echo "$i n'est pas un nom valide"
    fi
done