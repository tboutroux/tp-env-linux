#!/bin/bash

declare -A roles=(
    ["web"]="22,80,443"
    ["bdd"]="22,3306"

ajouter_regle_iptables() {
    role=$1
    port=$2
    iptables -A INPUT -p tcp --dport $port -j ACCEPT
    echo " Règle $port ajoutée pour $role"
}

deploiement() {
    for role in "${!roles[@]}"; do
        ports=${roles[$role]}
        IFS=',' read -ra port_array <<< "$ports"
        for port in "${port_array[@]}"; do
            add_rule "$role" "$port"
        done
    done
}

enregistrement() {
    iptables-save > /etc/iptables/rules.v4
    echo "Règles iptables enregistrées dans /etc/iptables/rules.v4"
}

#Execution des fonctions
deploiement
enregistrement