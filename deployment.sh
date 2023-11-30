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

# Boucle pour parcourir toutes les lignes du fichier csv avec la commande ssh
for i in $(cat $CSV_FILE | cut -d ',' -f 1); do
    if [ $i == "web" ]; then
        # Déployer des règles iptables pour la machine web
        command_ssh $i "sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT; sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT; sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT; sudo sh -c 'iptables-save > /etc/iptables/rules.v4'"
    elif [ $i == "bdd" ]; then
        # Déployer des règles iptables pour la machine de base de données
        command_ssh $i "sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT; sudo sh -c 'iptables-save > /etc/iptables/rules.v4'"
    else
        echo "$i n'est pas un nom valide"
    fi
done