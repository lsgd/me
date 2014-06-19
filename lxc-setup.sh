#!/bin/bash

# Helper script to do initial setup for a LXC debian container

LXC_PATH="/var/lib/lxc"
TPL_PATH="/srv/lxc-data"
INTERNAL_IP_PREFIX="10.1.1."

run_ssh_cmd() {
  local CMD=$1
  ssh -oStrictHostKeyChecking=no root@${INTERNAL_IP_PREFIX}${IP} "${CMD}" 1>> /tmp/lxc-install-${NAME}.log 2>> /tmp/lxc-install-${NAME}.log
}

echo
echo "***********************************************"
echo "         Setup a debian LXC container"
echo "***********************************************"
echo
printf 'Enter container name: '
read -r NAME

if [ "${NAME}" == "" ]; then
  echo "You have to specify the container name!"
  echo "Aborted!"
  exit
fi

if [ ! -d "${LXC_PATH}/${NAME}" ]; then
  echo "The container with name \"${NAME}\" could not be found!"
  echo "Aborted!"
  exit
fi


printf "Enter IP: ${INTERNAL_IP_PREFIX}"
read -r IP

if ! [[ "${IP}" =~ ^[0-9]+$ ]] ; then
  echo "The IP address has to contain only numbers!"
  echo "Aborted!"
  exit
fi

# Stop LXC container
echo "  * Stop LXC container"
lxc-stop -n ${NAME}


# path to container
C_PATH="${LXC_PATH}/${NAME}"

# copy setting files for user root
echo "  * Copy setting files for user root"
cp ${TPL_PATH}/.zshrc ${C_PATH}/rootfs/root/
cp ${TPL_PATH}/.vimrc ${C_PATH}/rootfs/root/

echo "  * Copy cronjob files"
cp ${TPL_PATH}/cronjob-clear-cached-memory.sh ${C_PATH}/rootfs/srv/cronjob-clear-cached-memory.sh

echo "  * Copy admintools"
cp -R ${TPL_PATH}/admintools ${C_PATH}/rootfs/srv/

# set own apt sources
echo "  * Set new apt source"
cp ${TPL_PATH}/sources.list ${C_PATH}/rootfs/etc/apt/

# configure network for container
echo "  * Configure network for container"
sed "s/{NAME}/$NAME/g" ${TPL_PATH}/config >${C_PATH}/config
sed -i "s/{IP}/$IP/g" ${C_PATH}/config

# empty banner after login
echo "  * Empty banner after login"
rm ${C_PATH}/rootfs/etc/motd
touch ${C_PATH}/rootfs/etc/motd

# add container to auto start
echo "  * Add container to auto start"
if [ ! -f "/etc/lxc/auto/${NAME}" ]; then
  ln -s ${C_PATH}/config /etc/lxc/auto/${NAME}
fi

# disable root login with password in SSH
echo "  * Disable root login with password via SSH"
sed -i "s/PermitRootLogin yes/PermitRootLogin without-password/g" ${C_PATH}/rootfs/etc/ssh/sshd_config

# add public ssh-keys from directory PATH_SSH_KEYS to VM root user
echo "  * Add public SSH keys to VM root user"
mkdir -p ${C_PATH}/rootfs/root/.ssh
if [ -f "${C_PATH}/rootfs/root/.ssh/authorized_keys" ]; then
  rm ${C_PATH}/rootfs/root/.ssh/authorized_keys
fi
touch ${C_PATH}/rootfs/root/.ssh/authorized_keys
KEY_FILES=`find ${TPL_PATH}/ssh-keys -type f -name '[^\.]*'`
for KF in $KEY_FILES
do
  echo "    * key $(basename $KF)"
  cat $KF >> ${C_PATH}/rootfs/root/.ssh/authorized_keys
done

# start container to install updates
echo "  * Start LXC container"
lxc-start -d -n ${NAME}

echo "  * Wait 30 seconds for LXC container to be started"
sleep 30

echo "  * Start installation"
echo "    * Update sources"
run_ssh_cmd "apt-get update"
#ssh -oStrictHostKeyChecking=no root@${INTERNAL_IP_PREFIX}${IP} "apt-get update && apt-get install -y aptitude" 1>> /tmp/lxc-install-${NAME}.log 2>> /tmp/lxc-install-${NAME}.log

echo
echo "    ======================================================"
echo "      USER INTERACTION NEEDED"
echo
echo "      Please run the following command on the machine"
echo "      and exit the ssh session after finishing it."
echo
echo "      $ apt-get upgrade -y && exit"
echo
echo "    ======================================================"
echo

ssh ${INTERNAL_IP_PREFIX}${IP}

echo
echo "    ======================================================"
echo

echo "    * Install aptitude"
run_ssh_cmd "apt-get install -y aptitude"
#ssh -oStrictHostKeyChecking=no root@${INTERNAL_IP_PREFIX}${IP} "apt-get install -y aptitude" 1>> /tmp/lxc-install-${NAME}.log 2>> /tmp/lxc-install-${NAME}.log

echo "    * Update sources"
run_ssh_cmd "aptitude update"

# 2014-05-08 - during upgrade, some packages could ask for user interaction --> cannot react --> hangs up

#echo "    * Upgrade system"
#run_ssh_cmd "aptitude update && aptitude upgrade -y && aptitude dist-upgrade -y"
#ssh -oStrictHostKeyChecking=no root@${INTERNAL_IP_PREFIX}${IP} "aptitude update && aptitude upgrade -y && aptitude dist-upgrade -y" 1>> /tmp/lxc-install-${NAME}.log 2>> /tmp/lxc-install-${NAME}.log

echo "    * Install mandatory applications"
run_ssh_cmd "aptitude install -y inetutils-ping inetutils-syslogd less zsh screen vim htop ncdu logrotate rkhunter && chsh -s \$(which zsh)"
#ssh -oStrictHostKeyChecking=no root@${INTERNAL_IP_PREFIX}${IP} "aptitude install -y inetutils-ping inetutils-syslogd less zsh screen vim htop ncdu logrotate rkhunter && chsh -s \$(which zsh)" 1>> /tmp/lxc-install-${NAME}.log 2>> /tmp/lxc-install-${NAME}.log

echo "    * Update rkhunter"
run_ssh_cmd "rkhunter --update"
run_ssh_cmd "rkhunter --propupd"
#ssh -oStrictHostKeyChecking=no root@${INTERNAL_IP_PREFIX}${IP} "rkhunter --update" 1>> /tmp/lxc-install-${NAME}.log 2>> /tmp/lxc-install-${NAME}.log
#ssh -oStrictHostKeyChecking=no root@${INTERNAL_IP_PREFIX}${IP} "rkhunter --propupd" 1>> /tmp/lxc-install-${NAME}.log 2>> /tmp/lxc-install-${NAME}.log

echo "    * Install cronjob (clear cached memory)"
run_ssh_cmd "crontab -l 2> /dev/null | { cat; echo \"13 5 * * * /srv/cronjob-clear-cached-memory.sh\"; } | crontab -"
run_ssh_cmd "chown root:root /srv/cronjob-clear-cached-memory.sh && chmod +x /srv/cronjob-clear-cached-memory.sh"

echo "  * Configure backup"
run_ssh_cmd "mkdir /backup"

echo
echo
echo "Finished!"
echo
echo "The install log can be found in /tmp/lxc-install-${NAME}.log"
echo


exit 1
