FROM openjdk:8u181-jdk-alpine3.8

MAINTAINER thimico

ENV JBOSS_VERSION='jboss-eap-6.4'                                                                      \
    JBOSS_EAP_PATCH='6.4.0'                                                                            \
    JBOSS_USER='jboss'
ENV ADMIN_USER='admin'                                                                                 \
    ADMIN_PASSWORD='Admin.123'                                                                         \
    JBOSS_USER_HOME="/home/${JBOSS_USER}"                                                              \
    DOWNLOAD_BASE_URL="https://github.com/daggerok/${JBOSS_VERSION}/releases/download"
ENV JBOSS_HOME="${JBOSS_USER_HOME}/${JBOSS_VERSION}"                                                   \
    ARCHIVES_BASE_URL="${DOWNLOAD_BASE_URL}/archives"                                                  \
    PATCHES_BASE_URL="${DOWNLOAD_BASE_URL}/${JBOSS_EAP_PATCH}"
ENV PATH="${JBOSS_HOME}/bin:/tmp:${PATH}"
USER root
RUN ( apk fix     --no-cache || echo 'cannot fix.'         )                                        && \
    ( apk upgrade --no-cache || echo 'cannot upgrade.'     )                                        && \
    ( apk cache   -v   clean || echo 'cannot clean cache.' )                                        && \
      apk add     --no-cache --update --upgrade                                                        \
                  busybox-suid bash wget ca-certificates unzip sudo openssh-client shadow           && \
    echo "${JBOSS_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers                                    && \
    sed -i 's/.*requiretty$/Defaults !requiretty/' /etc/sudoers                                     && \
    adduser -h ${JBOSS_USER_HOME} -s /bin/bash -D ${JBOSS_USER} ${JBOSS_USER}                       && \
    usermod -a -G ${JBOSS_USER} ${JBOSS_USER}
USER ${JBOSS_USER}
CMD /bin/bash
ENTRYPOINT standalone.sh
EXPOSE 8080 8443 9990 9999
WORKDIR /tmp
ADD --chown=jboss ./install.sh .
RUN wget ${ARCHIVES_BASE_URL}/jce_policy-8.zip                                                         \
         -q --no-cookies --no-check-certificate -O /tmp/jce_policy-8.zip                            && \
    unzip -q /tmp/jce_policy-8.zip -d /tmp                                                          && \
    ( sudo mv -f ${JAVA_HOME}/lib/security ${JAVA_HOME}/lib/backup-security || echo 'no backups.' ) && \
    sudo mv -f /tmp/UnlimitedJCEPolicyJDK8 ${JAVA_HOME}/lib/security                                && \
    wget ${ARCHIVES_BASE_URL}/jboss-eap-6.4.0.zip                                                      \
         -q --no-cookies --no-check-certificate -O /tmp/jboss-eap-6.4.0.zip                         && \
    unzip -q /tmp/jboss-eap-6.4.0.zip -d ${JBOSS_USER_HOME}                                         && \
    add-user.sh ${ADMIN_USER} ${ADMIN_PASSWORD} --silent                                            && \
    echo 'JAVA_OPTS="-Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0"             \
         ' >> ${JBOSS_HOME}/bin/standalone.conf                                                     && \
    sudo apk del --no-cache --no-network --purge                                                       \
                 busybox-suid unzip openssh-client shadow                                           && \
    sudo rm -rf /tmp/*.zip /tmp/*.tar.gz /var/cache/apk /var/lib/apk /etc/apk/cache || echo 'oops'  && \
    ( standalone.sh --admin-only                                                                       \
        & ( sudo chmod +x /tmp/install.sh && install.sh && rm -rf /tmp/install.sh ) )
WORKDIR ${JBOSS_USER_HOME}

## docker run --name jboss -itd -p 7070:8080 thimico/jboss:eap-6.4