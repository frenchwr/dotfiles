#!/bin/bash
#
# Script for deploying dotfiles to your home directory.
#

if [ $# -ne 1 ]; then
   echo "Usage: $0 ENV"
   exit 1
fi

ENV=$(echo $1 | tr -d '/')

if [ ! -d ${ENV} ]; then
   echo "${ENV} not a subdirectory!"
   exit 1
fi

for FILE in $(ls $ENV);
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

   SOURCE_FILE=${PWD}/${ENV}/${FILE}
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

if [ ${SHELL} = "/bin/bash" ]; then
   echo " "
   echo "To source your shell init files:"
   echo "source ~/.bashrc && source ~/.bash_profile"
fi
echo " "
git remote set-url origin git@github.com:frenchwr/dotfiles.git
echo "To fetch your GH private key, ssh to a machine containing the key and run:"
echo "ssh ~/.ssh/id_rsa ${USER}@${HOSTNAME}:~/.ssh/"
echo " "
