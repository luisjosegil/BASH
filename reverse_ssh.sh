#!/bin/bash
# Activate debugging
#set -x
cd ~/LABO/BASH
# GLOBAL VARIABLES ----------------
source ./config.reverse_ssh

# Import common functions to kill processes
#source ./functions_kill

function retrieve_miner_id {
        local machine_id=$( cat /etc/hostname | sed 's/[^0-9]*//g' )
        echo "$machine_id"
}

function calc_reverse_ssh_port {
        local machine_id=$(retrieve_miner_id)
        local new_port=$(($SSH_REVERSE_PORT_BASE + $(($MINER_GROUP*10)) +$machine_id ))
        echo "$new_port"
}

function check_if_ssh_exists {
        local remote_user_machine=$1
        local remote_port=$2
        local port_local=$3
        local port_tunnel=$4
        local result=$(ps -ef | grep ssh | grep $port_tunnel:localhost:$port_local | grep ljcd@$remote_user_machine | grep -v grep | awk '{ print $2 }')
        if [ -z $result ]
        then
                echo "$FALSE"
        else
                echo "$TRUE"
        fi
}

function reverse_ssh {
        local remote_host=${1}
        local remote_host_ssh_port=${2}
        local port_local=${3}
        local port_tunnel=${4}

        if (( $(check_if_ssh_exists ${remote_host} ${remote_host_ssh_port} ${port_local} ${port_tunnel} )==$FALSE ));
        then
                sudo -u ljcd -H sh \
                -c "ssh -fN -i ${PATH_RSA_PPK} -p${remote_host_ssh_port} -R ${port_tunnel}:localhost:${port_local} ljcd@${remote_host} cat -"
        fi
        sleep 5
}

# Howto
# reverse_ssh server server_port tunnel_on_local

while true
do
        # aquí falta un puerto!!!
        reverse_ssh ${LOCAL_SERVER_SSH} ${LOCAL_SERVER_SSH_PORT} ${LOCAL_SSH_PORT} $(calc_reverse_ssh_port)
        reverse_ssh ${CLOUD_SERVER_SSH} ${CLOUD_SERVER_SSH_PORT} ${LOCAL_SSH_PORT} $(calc_reverse_ssh_port)

        if (( $TESTING == $TRUE ));
        then
                /bin/sleep $MINS_TO_SLEEP
        else
                /bin/sleep $(($MINS_TO_SLEEP*60))
        fi
done
exit 0
