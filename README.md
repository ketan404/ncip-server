# NCIP Server for Koha

## Installation

### For package sites, become the instance user

```bash
sudo koha-shell <instance>
```

### Clone the git repository for the NCIP server

```bash
git clone https://github.com/bywatersolutions/ncip-server.git
```

### Become your own user again

```bash
exit
```

### Install dependancies

Install cpanminus:
```bash
curl -L https://cpanmin.us | sudo perl - App::cpanminus
```

Install the ncip-server dependancies using cpanm
```bash
sudo cpanm --installdeps .
```

### For package sites, become the instance user

```bash
sudo koha-shell <instance>
```

### Set up config.yml

Copy the config.yml.example file to config.yml

```bash
cd ncip-server
cp config.yml.example config.yml
```

Edit the `views: "/path/to/ncip-server/templates/"` line to point to the actual path you have the ncip-server template directory at. For whatever reason, this must be an absolute path and must be configured on a per-installation basis.

### Become your own user again

```bash
exit
```

### Set up the Init script

Copy the `init-script-template` file to your init directory. For Debian, you would copy it to init.d:
```bash
sudo cp init-script-template /etc/init.d/ncip-server
```

Edit the file you just created:
* Update the line `export KOHA_CONF="/path/to/koha-conf.xml"` to point to your production `koha-conf.xml` file. 
* Update the line `HOME_DIR="/home/koha"` to point to the Koha home directory. For Koha package installtions, that would be /var/lib/koha/<instancename>
* Update various other path definitions as necessary
* You may also change the port to a different port if 3001 is already being used on your server.

Configure the init script to run at boot
```bash
sudo update-rc.d ncip-server defaults
```
### Expose the ncip-server to the outside world

Modify you Koha Apache configuration, in the Intranet section, add the following:
```apache
ProxyPass /ncip http://127.0.0.1:3001 retry=0
ProxyPassReverse /ncip  http://127.0.0.1:3001 retry=0
```

### Enable ModProxy for apache
```bash
LoadModule proxy_module /usr/lib/apache2/modules/mod_proxy.so
LoadModule proxy_http_module /usr/lib/apache2/modules/mod_proxy_http.so
ProxyPass /ncip http://127.0.0.1:3001 retry=0
ProxyPassReverse /ncip  http://127.0.0.1:3001 retry=0
```

### Start the server!
```bash
sudo /etc/init.d/ncip-server start
```
