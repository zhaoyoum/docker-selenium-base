FROM ubuntu:focal-20201106
LABEL authors="Selenium <selenium-developers@googlegroups.com>"
#================================================
# Customize sources for apt-get
#================================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu focal main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu focal-updates main universe\n" >> /etc/apt/sources.list \
  && echo "deb http://security.ubuntu.com/ubuntu focal-security main universe\n" >> /etc/apt/sources.list

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

#========================
# Miscellaneous packages
# Includes minimal runtime used for executing non GUI Java programs
#========================
RUN apt-get -qqy update \
  && apt-get -qqy --no-install-recommends install \
    bzip2 \
    ca-certificates \
    openjdk-8-jre-headless \
    tzdata \
    sudo \
    unzip \
    wget \
    jq \
    curl \
    supervisor \
    gnupg2 \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

#===================
# Timezone settings
# Possible alternative: https://github.com/docker/docker/issues/3359#issuecomment-32150214
#===================
ENV TZ "UTC"
RUN echo "${TZ}" > /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata

#========================================
# Add normal user and group with passwordless sudo
#========================================
RUN groupadd seluser \
         --gid 1201 \
  && useradd seluser \
         --create-home \
         --gid 1201 \
         --shell /bin/bash \
         --uid 1200 \
  && usermod -a -G sudo seluser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'seluser:secret' | chpasswd
ENV HOME=/home/seluser

#======================================
# Add Grid check script
#======================================
COPY check-grid.sh entry_point.sh /opt/bin/

#======================================
# Add Supervisor configuration file
#======================================
COPY supervisord.conf /etc

#==========
# Selenium & relaxing permissions for OpenShift and other non-sudo environments
#==========
RUN  mkdir -p /opt/selenium /var/run/supervisor /var/log/supervisor \
  && touch /opt/selenium/config.json \
  && chmod -R 777 /opt/selenium /var/run/supervisor /var/log/supervisor /etc/passwd \
  && wget --no-verbose https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar \
    -O /opt/selenium/selenium-server-standalone.jar \
  && chgrp -R 0 /opt/selenium ${HOME} /var/run/supervisor /var/log/supervisor \
  && chmod -R g=u /opt/selenium ${HOME} /var/run/supervisor /var/log/supervisor

#===================================================
# Run the following commands as non-privileged user
#===================================================
USER 1200:1201


CMD ["/opt/bin/entry_point.sh"]
