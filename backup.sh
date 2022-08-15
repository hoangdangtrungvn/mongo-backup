#!/bin/sh

# This PARENT_FOLDER is a reference to a Google Drive folder in your account (like, "my-backups").
# Use gdrive list to get the ID of the folder you want
PARENT_FOLDER=

DB_HOST=
DB_USER=
DB_PASS=
DB_NAME=

DB_DATE=$(date +%d-%m-%Y_%H.%M.%S)
DB_DEST=/tmp/mongodb/backup
DB_FILE=${DB_DEST}/${DB_NAME}_${DB_DATE}.gz

[ -d ${DB_DEST} ] || mkdir -p ${DB_DEST}

# Delete old backups
CURRENT_DATE=$(date +%Y-%m-%d)
BACKUP_FOLDER=$(date --date="${CURRENT_DATE} - 2 days" +%d-%m-%Y)
BACKUP_FOLDER_ID=$(gdrive list --query " '${PARENT_FOLDER}' in parents" | grep "${BACKUP_FOLDER}" | sed -e "s/\(.*\)\s\s\s${BACKUP_FOLDER}.*/\1/")

[ ! -z ${BACKUP_FOLDER_ID} ] && gdrive delete -r ${BACKUP_FOLDER_ID}

# Dump file
mongodump --host ${DB_HOST} -u ${DB_USER} -p ${DB_PASS} -d ${DB_NAME} --archive=${DB_FILE}

# Upload file to Google Drive
UPLOAD_FOLDER=$(date +%d-%m-%Y)
UPLOAD_FOLDER_ID=$(gdrive list --query " '${PARENT_FOLDER}' in parents" | grep "${UPLOAD_FOLDER}" | sed -e "s/\(.*\)\s\s\s${UPLOAD_FOLDER}.*/\1/")

[ -z ${UPLOAD_FOLDER_ID} ] && UPLOAD_FOLDER_ID=$(gdrive mkdir -p ${PARENT_FOLDER} ${UPLOAD_FOLDER} | sed -e "s/Directory\s\(.*\)\screated/\1/")

gdrive upload -p ${UPLOAD_FOLDER_ID} ${DB_FILE}

# Remove file after successful upload
rm -rf ${DB_FILE}
