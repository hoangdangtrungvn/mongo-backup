#!/bin/sh

echo "==========================================="
echo "MONGO DATABASE BACKUP - $(date +%d-%m-%Y_%H.%M.%S)"
echo "==========================================="


##################################################
# This PARENT_FOLDER is a reference to a Google Drive folder in your account (like, "my-backups").
# Use gdrive list to get the ID of the folder you want
PARENT_FOLDER=

# Database config
DB_HOST=
DB_USER=
DB_PASS=
DB_NAME=
##################################################

##################################################
# Set default values
DB_DATE=$(date +%d-%m-%Y_%H.%M.%S)
DB_DEST=/tmp/mongodb/backup
DB_FILE=${DB_DEST}/${DB_NAME}_${DB_DATE}.zip

# Create temp directory
[ -d ${DB_DEST} ] || mkdir -p ${DB_DEST}
##################################################



##################################################
echo "==========================================="
echo "Delete old backups"
echo "==========================================="

CURRENT_DATE=$(date +%Y-%m-%d)
BACKUP_FOLDER=$(date --date="${CURRENT_DATE} - 2 days" +%d-%m-%Y)
BACKUP_FOLDER_ID=$(gdrive list --query " '${PARENT_FOLDER}' in parents" | grep "${BACKUP_FOLDER}" | sed -e "s/\(.*\)\s\s\s${BACKUP_FOLDER}.*/\1/")

[ ! -z "${BACKUP_FOLDER_ID}" ] && gdrive delete -r ${BACKUP_FOLDER_ID}
##################################################



##################################################
echo "==========================================="
echo "Dump database"
echo "==========================================="

mongodump -h=${DB_HOST} -u=${DB_USER} -p=${DB_PASS} -d=${DB_NAME} -o=${DB_DEST}
##################################################



##################################################
echo "==========================================="
echo "Compress database"
echo "==========================================="

zip -r ${DB_FILE} ${DB_DEST}/${DB_NAME}
##################################################



##################################################
echo "==========================================="
echo "Upload file to Google Drive"
echo "==========================================="

UPLOAD_FOLDER=$(date +%d-%m-%Y)
UPLOAD_FOLDER_ID=$(gdrive list --query " '${PARENT_FOLDER}' in parents" | grep "dir" | grep "${UPLOAD_FOLDER}" | sed -e "s/\(.*\)\s\s\s${UPLOAD_FOLDER}.*/\1/")

[ -z "${UPLOAD_FOLDER_ID}" ] && UPLOAD_FOLDER_ID=$(gdrive mkdir -p ${PARENT_FOLDER} ${UPLOAD_FOLDER} | sed -e "s/Directory\s\(.*\)\screated/\1/")

gdrive upload -p ${UPLOAD_FOLDER_ID} ${DB_FILE}
##################################################



##################################################
echo "==========================================="
echo "Remove temp files"
echo "==========================================="

rm -rf ${DB_DEST}/*
##################################################
