# Mongo Backup

### Install Google Drive CLI
```
sudo wget https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_386.tar.gz
sudo tar -xvf gdrive_2.1.1_linux_386.tar.gz
sudo mv gdrive /usr/local/bin
sudo ln -s /usr/local/bin/gdrive /usr/bin/gdrive
sudo gdrive about
```
In the console you will see an authentication URL that you can click and open in the browser to obtain an auth token.<br>
When the URL opens in the browser, just select your account and copy the auth token that is displayed on the next screen.

### Backup Configs
Open `backup.sh` and modify
```
DB_HOST=
DB_USER=
DB_PASS=
DB_NAME=
PARENT_FOLDER=
```

### Create Job
Open `/etc/crontab` and add to end<br>
```
0 */8   * * *   root    bash /path/to/backup.sh
```
