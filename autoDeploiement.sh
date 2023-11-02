#!/bin/bash

# Fichier CSV contenant les informations de connexion
# Le chemin d'un fichier dans un script bash ne devrait pas utiliser des antislashes (\)
# Utilisez plutôt des slashes (/)
CSV_FILE="/c/Users/Hugo/Desktop/Bash/tp-env-linux/ip.csv"

# Demander le mot de passe sudoers une seule fois au lieu de le faire à chaque tour de boucle
OLDMODE=$(stty -g)
stty -echo
read -p "sudoers password: " SUDOPASS
stty $OLDMODE

USER1=$(cat $CSV_FILE | cut -d ',' -f1 | sed -n 1p)
HOST1=$(cat $CSV_FILE | cut -d ',' -f2 | sed -n 1p)
USER2=$(cat $CSV_FILE | cut -d ',' -f1 | sed -n 2p)
HOST2=$(cat $CSV_FILE | cut -d ',' -f2 | sed -n 2p)

# Lire chaque ligne du fichier CSV

# Connexion SSH et mise à jour des paquets
echo $SUDOPASS | ssh -tt $USER1@$HOST1 "sudo apt-get update && sudo apt dist-upgrade"

ssh -tt $USER2@$HOST2 -T << EOF  
    sudo -S apt-get update
EOF