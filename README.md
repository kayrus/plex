# plex
Plex image for armhf Docker

## Build

### Manual download

```sh
wget https://downloads.plex.tv/plex-media-server/1.0.0.2261-a17e99e/PlexMediaServer-1.0.0.2261-a17e99e-arm7.spk
docker build -t plex .
```

### Direct download

```sh
docker build -f Dockerfile_remote -t plex .
```

## Run

```sh
docker run --name plex --rm -p ${PLEX_OUT_PORT}:${PLEX_INT_PORT} -v ${CONFIG_DIR}:/var/lib/plex -v ${MEDIA_LIB}:/media plex
```

### Prevent login request for the non-docker bridge requests

```sh
iptables -t nat -I POSTROUTING -o docker0 -p tcp -m tcp --dport ${PLEX_INT_PORT} -j MASQUERADE
```

### systemd

`plex.service` already contains all the necessary commands to run plex. Just place this file into the `/etc/systemd/system/` directory, modify its environment variables, run `sudo systemctl daemon-reload` and start plex:

```sh
sudo systemctl start plex
```
