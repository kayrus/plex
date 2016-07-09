FROM armv7/armhf-ubuntu:14.04.3
MAINTAINER kayrus

RUN mkdir -p /opt/plex/Application && mkdir -p /tmp/plex
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && apt-get install -yy -q wget \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Download Synology Apline-ARMV7 archive and extract it (https://plex.tv/downloads#pms-nas)
ADD PlexMediaServer-1.0.0.2261-a17e99e-arm7.spk /tmp/PlexMediaServer-1.0.0.2261-a17e99e-arm7
RUN tar -xf /tmp/PlexMediaServer-1.0.0.2261-a17e99e-arm7/package.tgz -C /opt/plex/Application && rm -rf /tmp/PlexMediaServer-1.0.0.2261-a17e99e-arm7
# Add plex user
RUN useradd -r -d /var/lib/plex -s /sbin/nologin plex
# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
# Start container using plex user
USER plex
VOLUME ["/var/lib/plex","/media"]
# Plex web interface default port
EXPOSE 32400/tcp
WORKDIR /opt/plex/Application
ADD start.sh /opt/plex/Application/start.sh
ENTRYPOINT /opt/plex/Application/start.sh
