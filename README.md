# plex

Plex Docker image for armhf. Tested on armbian and Cubietruck.

## Build

### Manual download

Get the URL:

```sh
# x31plus arch contains binaries with compiled ARM NEON extension support
$ curl -s https://plex.tv/api/downloads/1.json | python -mjson.tool | grep x31plus
                    "url": "https://downloads.plex.tv/plex-media-server/1.0.3.2461-35f0caa/PlexMediaServer_1.0.3.2461-35f0caa_arm-x31plus.qpkg"
```

```sh
$ wget https://downloads.plex.tv/plex-media-server/1.0.3.2461-35f0caa/PlexMediaServer_1.0.3.2461-35f0caa_arm-x31plus.qpkg
$ ./build.sh
```

### Manual download with special "Plex Transcoder" wrapper

Wrapper fixes issue described in this [topic](http://forums.plex.tv/discussion/comment/1216192) (at least in Chrome browser)

```sh
$ wget https://downloads.plex.tv/plex-media-server/1.0.3.2461-35f0caa/PlexMediaServer_1.0.3.2461-35f0caa_arm-x31plus.qpkg
$ ./build_magic.sh
```

## Run

```sh
export MEDIA_LIB=/home/user/media
export CONFIG_DIR=/var/lib/plex
export DOCKER_IMAGE=kayrus/plex
export PLEX_INT_PORT=32400
export PLEX_EXT_PORT=32400
docker run --name plex --rm -p ${PLEX_OUT_PORT}:${PLEX_INT_PORT} -v ${CONFIG_DIR}:/var/lib/plex -v ${MEDIA_LIB}:/media ${DOCKER_IMAGE}
```

### Prevent login request for the non-docker bridge requests

```sh
sudo iptables -t nat -I POSTROUTING -o docker0 -p tcp -m tcp --dport ${PLEX_INT_PORT} -j MASQUERADE
```

### systemd

`plex.service` already contains all the necessary commands to run plex. Just place this file into the `/etc/systemd/system/` directory, modify its environment variables, run `sudo systemctl daemon-reload` and start plex:

```sh
sudo systemctl start plex
```

### Errors on playing video files

Plex automatically downloads codecs and stores them inside `${CONFIG_DIR}/Library/Application Support/Plex Media Server/Codecs/ecd8c57-1099-linux-annapurna-arm7` directory, i.e.:

```sh
${CONFIG_DIR}/Library/Application Support/Plex Media Server/Codecs/ecd8c57-1099-linux-annapurna-arm7/libh264_decoder.so
```

You can download them manually in case when you don't have internet access:

```sh
wget https://downloads.plex.tv/codecs/ecd8c57-1099/linux-annapurna-arm7/libh264_decoder.so
wget https://downloads.plex.tv/codecs/ecd8c57-1099/linux-annapurna-arm7/libac3_decoder.so
wget https://downloads.plex.tv/codecs/ecd8c57-1099/linux-annapurna-arm7/libaac_decoder.so
wget https://downloads.plex.tv/codecs/ecd8c57-1099/linux-annapurna-arm7/libaac_encoder.so
```

### Performance issues on slow ARMv7 CPUs

Plex since v1.0.0 has a default profile for browsers which doesn't downmix 5.1 (6 channels) to stereo (2 channels). This causes performance issues when CPU encodes 6 channels instead of 2.

To resolve the issue, `Dockerfile` contains a script which enables downmix to stereo.

```Dockerfile
RUN sed -i 's/name="audio.channels" value="6"/name="audio.channels" value="2"/' /opt/plex/Application/Resources/Profiles/Web.xml
```

## nginx

This repository includes nginx config which you can configure to listen HTTPS socket.
