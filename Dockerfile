FROM thimico/jre7:latest

MAINTAINER thimico

ARG VERSION_ARG=6.4
ARG JBOSS_ADMIN_PASSWORD_ARG=admin123
ARG JBOSS_ADMIN_USER_ARG=admin

ENV VERSION=${VERSION_ARG} \
    JBOSS_ADMIN_PASSWORD=${JBOSS_ADMIN_PASSWORD_ARG} \
    JBOSS_ADMIN_USER=${JBOSS_ADMIN_USER_ARG}

ENV JBOSS_USER=jboss-eap-${VERSION}

ENV JBOSS_FILE=${JBOSS_USER}.0.zip \
    JBOSS_USER_HOME=/home/${JBOSS_USER}

ENV JBOSS_URL=https://github.com/daggerok/jboss/releases/download/eap/${JBOSS_FILE} \
    JBOSS_HOME=${JBOSS_USER_HOME}/${JBOSS_USER}

RUN apk --no-cache --update add bash wget ca-certificates unzip sudo
RUN wget -q ${JBOSS_URL} -O ${JBOSS_USER_HOME}/${JBOSS_FILE}
RUN unzip ${JBOSS_USER_HOME}/${JBOSS_FILE} -d ${JBOSS_USER_HOME} \
	rm -rf ${JBOSS_USER_HOME}/${JBOSS_FILE}
RUN addgroup ${JBOSS_USER}-group \
 && echo ${JBOSS_USER} ALL=(ALL) NOPASSWD: ALL >> /etc/sudoers \
 && sed -i "s/.*requiretty$/Defaults !requiretty/" /etc/sudoers \
 && adduser -h ${JBOSS_USER_HOME} -s /bin/bash -D -u 1025 ${JBOSS_USER} ${JBOSS_USER}-group \
 && usermod -a -G wheel ${JBOSS_USER} \
 && wget --no-cookies \
         --no-check-certificate \
         --header "Cookie: oraclelicense=accept-securebackup-cookie" \
                  "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" \
         -O /tmp/jce_policy-8.zip \
 && unzip -o /tmp/jce_policy-8.zip -d /tmp \
 && mv -f ${JAVA_HOME}/lib/security ${JAVA_HOME}/lib/backup-security || true \
 && mv -f /tmp/UnlimitedJCEPolicyJDK8 ${JAVA_HOME}/lib/security

USER ${JBOSS_USER}
WORKDIR ${JBOSS_USER_HOME}

ARG JAVA_OPTS_ARGS="\
 -Djava.net.preferIPv4Stack=true \
 -XX:+UnlockExperimentalVMOptions \
 -XX:+UseCGroupMemoryLimitForHeap \
 -XshowSettings:vm "

ENV JAVA_OPTS="${JAVA_OPTS} ${JAVA_OPTS_ARGS}"

CMD /bin/bash
EXPOSE 8080 9990 8443
ENTRYPOINT /bin/bash ${JBOSS_HOME}/bin/standalone.sh


RUN sudo apk --no-cache --no-network --purge del unzip \
 && sudo rm -rf /var/cache/apk/* /tmp/* 

RUN ${JBOSS_HOME}/bin/add-user.sh ${JBOSS_ADMIN_USER} ${JBOSS_ADMIN_PASSWORD} --silent \
 && echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> ${JBOSS_HOME}/bin/standalone.conf

RUN   mkdir /usr/share/fonts
RUN   mkdir /usr/share/fonts/truetrype
ADD content/Fonts /usr/share/fonts/truetrype
RUN fc-cache


############################################ USAGE ##############################################
# FROM thimico/jboss:eap-6.4                                                             		#
# HEALTHCHECK --timeout=2s --retries=22 \                                                       #
#         CMD wget -q --spider http://127.0.0.1:8080/my-service/health \                        #
#          || exit 1                                                                            #
# COPY --chown=jboss ./target/*.war ${JBOSS_HOME}/standalone/deployments/my-service.war         #
#################################################################################################

############################## DEBUG | MULTI-DEPLOYMENTS USAGE ##################################
# FROM thimico/jboss:eap-6.4                                                             		#
# # Debug:                                                                                      #
# ENV JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" #
# EXPOSE 5005                                                                                   #
# # Multi builds:                                                                               #
# COPY --chown=jboss ./target/*.war ${JBOSS_HOME}/standalone/deployments/                       #
#################################################################################################

#rodar o comando: docker run --name jbossdt -v ~/docker_volumes/jbossdt:/opt/jboss-as-7.1.1.Final/standalone -p 8080:8080 thimico/jboss:eap-6.4