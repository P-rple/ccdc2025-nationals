#! /bin/bash
#********************************
# Written by a sad Matthew Harper...
#********************************
# Check if the scrip is ran as root.
# $EUID is a env variable that contains the users UID
# -ne 0 is not equal zero
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Make central location for backup files
mkdir /backups

# Change ownership of the directory to root
chown root:root /backups
# Make it read-write for root but read for no others
chmod 600 /backups

echo "[+] Backing up old Bash to ~/copied-bash-history"
# Create user-histories directory
mkdir /backups/user-histories
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /backups/user-histories
# Make it read-write for root but read for others
chmod 644 /backups/user-histories


# Get all home directoriers where histories may be stored
UserHome="$(ls /home)"

# Loop through all users with home dirs, copy bash or zsh file.. May want to scan for all history types
for user in $UserHome
do
    result=$user"Primary-History"
    for history in $(ls -a /home/$user | awk '/\..*_history/{print}')
    do
      cp /home/$user/$history /backups/user-histories/$user$history
    done
done

## SSH
echo "[+] Backing up old SSH config to /backups/configs/sshd_configs"
# Create config directory
mkdir /backups/configs
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /backups/configs
# Make it read-write for root but read for others
chmod 644 /backups/configs
# Copy SSH Config
cp -r /etc/ssh/ /backups/configs/sshd_configs

## PAM
echo "[+] Backing up old PAM config to /backups/configs/pam"
# Create config directory
mkdir /backups/configs/pam
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /backups/configs/pam
# Make it read-write for root
chmod 644 /backups/configs/pam
# Copy to config directory
if [ -d "/etc/pam.d" ]; then
  cp -r /etc/pam.d /backups/configs/pam
fi
cp /etc/pam.conf /backups/configs/pam/pam.conf

## Firewall configs
echo "[+] Backing up old Firewall configs to /backups/firewall"
# Create config directory
mkdir /backups/firewall
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /backups/firewall
# Make it read-write for root but read for others
chmod 644 /backups/firewall
# Copy to config directory
if [ -d "/etc/iptables/" ]; then
  cp /etc/iptables/rules.v4 /backups/firewall/rules.v4
  cp /etc/iptables/rules.v6 /backups/firewall/rules.v6
elif [ -d "/etc/sysconfig/iptables/" ]; then
  cp /etc/sysconfig/iptables /backups/firewall/iptables
  cp /etc/sysconfig/ip6tables /backups/firewall/ip6tables
elif [ -d "/etc/firewalld/" ]; then
  cp /usr/lib/firewalld /backups/firewall/firewalld-system
  cp /etc/firewalld /backups/firewall/firewalld-user
else
  cp /etc/nftables.conf /backups/firewall/nftables.conf
fi

# UFW Configs
if [ -d "/etc/ufw" ]; then
  mkdir /backups/configs/ufw
  # Change ownership of the directory to root (explicit, should inherit from parent?)
  chown root:root /backups/configs/ufw
  # Make it read-write for root but only read for others
  chmod 644 /backups/configs/ufw
  # Copy entire directory (I am lazy, most all of it is configurable)
  cp -r /etc/ufw/user.rules /backups/configs/ufw/user.rules
fi

## Crontab
echo "[+] Backing up Crontab configs to /backups/crontabs/"
# Make Cron tab directory
mkdir /backups/configs/crontabs
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /backups/configs/crontabs
# Make it read-write for root but read for others
chmod 644 /backups/configs/crontabs

# Copy User Configurations
if [ -f /etc/redhat-release ]; then
  cp -r /var/spool/cron/ /backups/configs/crontabs
elif [ -f /etc/debian_version ]; then
  cp -r /var/spool/cron/crontabs /backups/configs/crontabs
else
  cp -r /var/cron/tabs /backups/configs/crontabs
fi

## Logs Directory
echo "[+] Backing up logs directory to /backups/logs/"
mkdir /backups/logs
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /backups/logs
# Make it read-write for root but read for others
chmod 644 /backups/logs
# Copy logs
cp -r /var/log /backups/logs

## Netplan
echo "[+] Backing up netplan directory to /backups/network/"
mkdir /backups/network
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /backups/network
# Make it read-write for root but read for others
chmod 644 /backups/network
# Copy logs
cp -r /etc/netplan /backups/network

# glusterfs configs
# if [ -d "/etc/glusterfs" ]; then

#   mkdir /backups/configs/gluster
#   # Change ownership of the directory to root (explicit, should inherit from parent?)
#   chown root:root /backups/configs/gluster
#   # Make it read-write for root but only read for others
#   chmod 644 /backups/configs/gluster
#   # Copy entire directory (I am lazy, most all of it is configurable)
#   cp -r /etc/glusterfs/ /backups/configs/gluster/
# fi

# Backup Auth Files -- In place
echo "[+] Backing up shadow file to shadow.bak (in-place)"
# Create user-histories directory
cp /etc/shadow /etc/shadow.bak
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /etc/shadow.bak
# Make it read-write for root but read for others
chmod 400 /etc/shadow.bak

echo "[+] Backing up passwd file to passwd.bak (in-place)"
# Create user-histories directory
cp /etc/passwd /etc/passwd.bak
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /etc/passwd.bak
# Make it read-write for root but read for others
chmod 400 /etc/passwd.bak

echo "[+] Backing up group file to group.bak (in-place)"
# Create user-histories directory
cp /etc/group /etc/group.bak
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /etc/group.bak
# Make it read-write for root but read for others
chmod 400 /etc/group.bak

echo "[+] Backing up gshadow file to gshadow.bak (in-place)"
# Create user-histories directory
cp /etc/gshadow /etc/gshadow.bak
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /etc/gshadow.bak
# Make it read-write for root but read for others
chmod 400 /etc/gshadow.bak

# Etc
echo "[+] Backing up etc directory to /backups/etc/"
mkdir /backups/etc
# Change ownership of the directory to root (explicit, should inherit from parent?)
chown root:root /backups/etc
# Make it read-write for root but read for others
chmod 644 /backups/etc
# Copy logs
cp -r /etc /backups/etc

echo "[!] Changing Attr on /backups [!]"

chattr +i /backups

echo "[?] Use \`chattr -i /backups\` to enable removal and writes [?]"
