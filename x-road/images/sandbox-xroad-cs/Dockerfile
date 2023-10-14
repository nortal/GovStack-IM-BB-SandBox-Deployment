FROM niis/xroad-central-server:focal-7.2.2

RUN \
     apt-get -qq update \
  && apt-get -qq install nano-tiny xroad-database-remote \
  && pg_dropcluster 14 main --stop \
  && apt-get -qq remove --purge postgresql \
  && apt-get -qq autoremove \
  && apt-get -qq clean


RUN rm -rf \
    /etc/xroad/db.properties \
    /etc/xroad.properties \
    /etc/xroad/ssl/*.crt \
    /etc/xroad/ssl/*.key \
    /etc/xroad/ssl/*.p12 \
    /var/log/syslog \
    /var/log/xroad/* \
    /var/log/postgresql

COPY --chown=xroad:xroad files/custom-fetch-pin.sh /usr/share/xroad/autologin/
# override logging config -- log to stdout
COPY --chown=xroad:xroad files/*logback*.xml /etc/xroad/conf.d/
COPY --chown=xroad:xroad files/override-sandbox.ini /etc/xroad/conf.d

RUN echo "XROAD_PARAMS=-XX:ActiveProcessorCount=2" >>/etc/xroad/conf.d/local.properties \
  && sed -i -E 's/^(\s*tar\s+)(--create -v --label .*)$/\1--ignore-failed-read \2/' /usr/share/xroad/scripts/_backup_xroad.sh

# create a backup of the configuration for version migration and
# for initializing an empty config volume
RUN mkdir -p \
  /usr/share/xroad/config/etc/xroad \
  /usr/share/xroad/config/backup \
  && cp -a /etc/xroad /usr/share/xroad/config/etc/ \
  && cp -a /home/ca /usr/share/xroad/config \
  && rm -rf /usr/share/xroad/config/etc/xroad/signer/softtoken \
  && mv /usr/share/xroad/config/etc/xroad/conf.d/local.ini \
    /usr/share/xroad/config/etc/xroad/services/local.properties \
    /usr/share/xroad/config/etc/xroad/devices.ini \
    /usr/share/xroad/config/backup/ \
  && dpkg-query --showformat='${Version}' --show xroad-center >/usr/share/xroad/config/VERSION \
  && cp /usr/share/xroad/config/VERSION /etc/xroad/VERSION \
  && sed -i 's/initctl/supervisorctl/g' /usr/share/xroad/scripts/_restore_xroad.sh

COPY --chown=root:root files/entrypoint.sh /root/entrypoint.sh
COPY --chown=root:root files/cs-xroad.conf /etc/supervisor/conf.d/xroad.conf
CMD ["/root/entrypoint.sh"]

EXPOSE 80 4000
