#!/bin/bash
#
# Script for deploying dotfiles to your home directory.
#

if [ $# -ne 2 ]; then
   echo "Usage: $0 ROLE ENV"
   exit 1
fi

ROLE=$(echo $1 | tr -d '/')
ENV=$2

if [ ! -d ${ROLE} ]; then
   echo "${ROLE} not a subdirectory!"
   exit 1
fi

for FILE in $(ls $ROLE);
do

   echo " "
   DOTFILE=${HOME}/"."${FILE}
   if [ -f ${DOTFILE} ]; then
      echo "Backing up existing ${DOTFILE} to ${DOTFILE}.bkp"
      cp ${DOTFILE}{,.bkp}
      if [ ! -f ${DOTFILE}.bkp ]; then
         echo "${DOTFILE}.bkp not found! Bailing!"
         exit 1
      fi
   fi

   SOURCE_FILE=${PWD}/${ROLE}/${FILE}
   echo "Sym linking ${DOTFILE} to ${SOURCE_FILE}..."
   ln -sf ${SOURCE_FILE} ${DOTFILE}
   if [ -L ${DOTFILE} ] ; then
      if [ -e ${DOTFILE} ] ; then
         echo "Success!"
      else
         echo "Failed! Bailing..."
	 exit 1
      fi
   elif [ -e ${DOTFILE} ] ; then
      echo "File exists but it's not a sym link...bailing"
      exit 1
   else
      echo "No file, no sym link...bailing"
      exit 1
   fi

done

if [ ${ENV} = "prod" ] ; then
   echo 'export PS1="\[\033[35m\]\t\[\033[m\]-\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$(parse_git_branch)$NO_COLOR\n\[\033[4;31m\]PROD$NO_COLOR\$ "' >> ${PWD}/${ROLE}/bash_profile
   echo " " >> ${PWD}/${ROLE}/bash_profile
elif [ ${ENV} = "staging" ] ; then
   echo 'export PS1="\[\033[35m\]\t\[\033[m\]-\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$(parse_git_branch)$NO_COLOR\n\[\033[36m\]staging$NO_COLOR\$ "' >> ${PWD}/${ROLE}/bash_profile
   echo " " >> ${PWD}/${ROLE}/bash_profile
else
   echo "Custom prompt not found for environment ${ENV}. Only 'prod' and 'staging' supported."
   echo " "
fi

if [ ${SHELL} = "/bin/bash" ]; then
   echo " "
   echo "To source your shell init files:"
   echo "source ~/.bashrc && source ~/.bash_profile"
fi
echo " "
git remote set-url origin git@github.com:frenchwr/dotfiles.git
echo "To fetch your GH private key, ssh to a machine containing the key and run:"
echo "scp ~/.ssh/id_rsa ${USER}@${HOSTNAME}:~/.ssh/"
echo " "
