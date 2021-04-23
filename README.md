Quick Dirty iPhone Photo Backup Server
==

_Quick, dirty, i don't care! iPhone photo backup over internet._

## Dependencies

```
sudo apt install imagemagick ffmpeg -y
```

## Enable SSL

Generate key and certificate for that:

```
$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout puma-selfsigned.key -out puma-selfsigned.crt
```

## Running

Better to add as a service on the OS.

```
puma config.ru -C puma.rb
```

Default port: 9494

## As a Service

Adjust `dirtubackup.service` params

```
sudo cp dirtubackup.service /etc/systemd/system/
sudo systemctl start dirtubackup.service
sudo systemctl enable dirtubackup.service
```
