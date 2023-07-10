#!/bin/bash

MY_PATH="`dirname \"$0\"`"

user=`tail -n 1 /etc/shadow | cut -d ':' -f1`
# verify user is valid and has a home directory
ls /home | xargs | grep "$user"
if [[ $? -ne 0 ]]; then
    echo "User=$user does not have home directory, set \$user directly in script"
    exit 1
fi

function add_to_user_path() {
    local path_dir="$1"
    local user="${2:-$user}"
    path_dir="$path_dir" su -s /bin/bash -c 'echo PATH=\$PATH:$path_dir >> $HOME/.bashrc' -g "$user" "$user"
}

function append_to_user_bashrc() {
    local line="$1"
    local user="${2:-$user}"
    line="$line" su -s /bin/bash -c 'echo $line >> $HOME/.bashrc' -g "$user" "$user"
}

function user_exec() {
    local cmd="$1"
    local user="${2:-$user}"
    line="$cmd" su -s /bin/bash -c '$cmd' -g "$user" "$user"
}


apt-get update
apt-get upgrade -y

apt-get install -y telnet dnsutils curl vim wget screen

# Download some core setup related config files
wget 'https://gist.githubusercontent.com/codeniko/0337f460f6c25e977ca3308f668d6d21/raw/sshd_config' # check diff and move to /etc/ssh/sshd_config

### Move firewall rules to root dir and enable it on boot with systemd
cp "$MY_PATH/root/"* /root/
systemctl enable /root/load-iptables.service --now --system

cd /tmp/

### Final settings/configurations that should be most visible when finished

echo 'Downloaded sshd_config. Check diff and move to /etc/ssh/sshd_config when the first authorized_keys to ssh with have been added. See README for more help.'

append_to_user_bashrc "alias gen-ssh-key='ssh-keygen -t rsa -b 4096 -C '"
echo 'Use gen-ssh-key command to generate an ssh key. Pass email as argument'

