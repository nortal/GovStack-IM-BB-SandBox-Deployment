ARG XROAD_VERSION=7.2.2

FROM niis/xroad-security-server-sidecar:$XROAD_VERSION

RUN echo "XROAD_PARAMS=-XX:ActiveProcessorCount=2" >>/usr/share/xroad/config/backup/local.properties \
  && sed -i -E 's/^(\s*tar\s+)(--create -v --label .*)$/\1--ignore-failed-read \2/' /usr/share/xroad/scripts/_backup_xroad.sh

ENV DEBIAN_FRONTEND=noninteractive
COPY files/entrypoint.sh /root/entrypoint.sh
CMD ["/root/entrypoint.sh"]
