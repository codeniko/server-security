# Server setup scripts

### Setup a unix server
Follow these steps to setup a unix server and the projects. The script here specifically is for Debian linux distro with SystemD but can work for any linux distro with slight modifications. Dont add private github ssh keys into the server and access any repos directly. If the server ever gets compromised, you risk the attacker gaining access to the repos on github and possibly deleting them.

Git clone repo into user's home directory and then run the setup command.

```shell
sudo ./setup/debian-node-server-setup.sh
```

This will install update all latest packages for debian, download a `sshd_config` file to use later after you add the the public keys for password-less SSH.

### Setup SSH with SSL identity keys (passwordless SSH)
You'll need a pair of public and private RSA keys on your computer. If you don't have any, you can generate a pair by running a terminal on your Mac or Unix computer and running `ssh-keygen -t rsa -b 4096 -C EMAIL` replacing EMAIL with your email address. If you have keys already, or after generating a pair, copy the entire contents of the public key and paste it into `/home/debian/.ssh/authorized_keys`. If there are multiple keys, put them each on on their own line.

If you don't have the `authorized_keys` or the `.ssh` directory, create it and change the permission to 600 for the file, and 700 for the directory.
```shell
mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

#### Test that SSH with the keys work
Restart the sshd service by running `sudo systemctl restart ssh`

Next you want to test that you can SSH into the server with your private key. From your macbook, run `ssh -i PRIVATE_KEY_FILE debian@IP` replacing PRIVATE_KEY_FILE with the location of your private RSA key, and IP with the server's IP. If all is well, continue to next section to disable passwords with SSH.

#### Finish setup and disable SSHing with passwords
Passwords are insecure and there are bots scouring the internet for open port 22s to try to break in. They use dictionary attacks with random usernames to try to guess the passwords and this is just non-stop. Disable SSH login with passwords and you won't have any problems.

The included debian-node-server-setup.sh script should have downloaded a `sshd_config` file. Simply move it into the right spot and restart to apply the new config. We'll also make a backup of the original just in case. The config is one [I made myself and reuse for my own projects](https://gist.githubusercontent.com/codeniko/0337f460f6c25e977ca3308f668d6d21/raw/sshd_config)
```shell
sudo cp sshd_config{,.backup}
sudo mv sshd_config /etc/ssh/sshd_config
sudo systemctl restart ssh
```

While staying signed in with your current SSH session incase anything goes wrong, you want to open a new terminal on your computer and attempt to ssh in again. If all is well, you're done. If not, bring back the backup and restart the service again.

### Firewall rules (iptables)
When the setup script is run, the firewall rules and service files are moved to `/root/` directory to use by the system. The script enables a service to then apply these firewall rules on every boot. 

As of time of writing, the firewall rules block all incoming traffic except for SSH (port 22), HTTP (port 80), HTTPS (port 443), and several SMTP protocols to allow pinging the servers.
