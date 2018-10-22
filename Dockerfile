FROM openjdk:8u151-jdk-alpine

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
