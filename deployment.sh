#!/bin/bash

declare -A roles=(
    ["web"]="22,80,443"
    ["bdd"]="22,3306"
)

# Fonction pour ajouter des règles iptables
ajouter_regle_iptables() {
    ip_address=$1
    role=$2
    iptables -A INPUT -p tcp --dport $port -j ACCEPT
    echo "Added rule for $role with IP address: $ip_address"
}

# Déploiement des règles à partir du fichier CSV
deploiement() {
    tail -n +2 roles.csv | while IFS=',' read -r role ip_address; do
        ajouter_regle_iptables "$ip_address" "$role"
    done
}

# Enregistrement des règles iptables
enregistrement() {
    iptables-save > /etc/iptables/rules.v4
    echo "Règles iptables enregistrées"
}

#Execution des fonctions
deploiement
enregistrement

