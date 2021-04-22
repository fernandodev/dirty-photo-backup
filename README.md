Quick Dirty iPhone Photo Backup Server
==

_Quick, dirty, i don't care! iPhone photo backup over internet._

## Dependencies

```
sudo apt install imagemagick ffmpeg -y
```

## Running

Better to add as a service on the OS.

```
puma config.ru -C puma.rb
```

Default port: 9494