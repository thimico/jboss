FROM thimico/jdk8:latest

MAINTAINER thimico

ARG VERSION_ARG=6.4
ARG JBOSS_ADMIN_PASSWORD_ARG=admin@123
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
RUN mkdir -p ${JBOSS_HOME}
RUN apk --no-cache --update add busybox-suid bash wget ca-certificates unzip sudo openssh-client \
&& wget --no-cookies \
         --no-check-certificate \
         --header "Cookie: oraclelicense=accept-securebackup-cookie" \
                  "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" \
         -O /tmp/jce_policy-8.zip \
 && unzip -o /tmp/jce_policy-8.zip -d /tmp \
 && mv -f ${JAVA_HOME}/lib/security ${JAVA_HOME}/lib/backup-security || true \
 && mv -f /tmp/UnlimitedJCEPolicyJDK8 ${JAVA_HOME}/lib/security

WORKDIR ${JBOSS_USER_HOME}

ARG JAVA_OPTS_ARGS="\
 -Djava.net.preferIPv4Stack=true \
 -XX:+UnlockExperimentalVMOptions \
 #-XX:+UseCGroupMemoryLimitForHeap \
 -XshowSettings:vm \
 -Xss128m -Xms8192m -Xmn1024m -Xmx8192m "

 ENV JAVA_OPTS="${JAVA_OPTS} ${JAVA_OPTS_ARGS}"


CMD /bin/bash
EXPOSE 8080 9990 8443
ENTRYPOINT /bin/bash ${JBOSS_HOME}/bin/standalone.sh

RUN wget -q ${JBOSS_URL} -O ${JBOSS_USER_HOME}/${JBOSS_FILE}  \
 && unzip ${JBOSS_USER_HOME}/${JBOSS_FILE} -d ${JBOSS_USER_HOME} \
 && rm -rf ${JBOSS_USER_HOME}/${JBOSS_FILE} \
 && apk --no-cache --no-network --purge del busybox-suid unzip \
 && rm -rf /var/cache/apk/* /tmp/* \
 && ${JBOSS_HOME}/bin/add-user.sh ${JBOSS_ADMIN_USER} ${JBOSS_ADMIN_PASSWORD} --silent \
 && echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> ${JBOSS_HOME}/bin/standalone.conf

## docker run --name jboss -itd -p 7070:8080 thimico/jboss:eap-6.4