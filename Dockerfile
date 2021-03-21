FROM thimico/jre8:latest

MAINTAINER thimico

ENV JBOSS_HOME /opt/wildfly-10.0.0.Final
ENV JBOSS_VERSION = 10.0.0
WORKDIR /build

# Instalar libreoffice
 RUN   apk update \                                                                                                                                                                                                                        
  &&   apk add ca-certificates wget \                                                                                                                                                                                                      
  &&   update-ca-certificates libreoffice msttcorefonts-installer update-ms-fonts fontconfig  terminus-font

RUN mkdir -p /opt \
 && apk add --update bash && rm -rf /var/cache/apk/* \
 && wget http://download.jboss.org/wildfly/10.0.0.Final/wildfly-10.0.0.Final.tar.gz \
 && tar -zxf wildfly-10.0.0.Final.tar.gz -C /opt \
 && rm -rf /build

ADD content/libreoffice_iniciar.sh /usr/bin/libreoffice_iniciar.sh
ADD content/sofficerc /etc/sofficerc
ADD content/selodigital.txt /opt/wildfly-10.0.0.Final
 RUN mkdir -p /opt/wildfly-10.0.0.Final/modules/org/postgres/main/mod
 ADD content/module.xml /opt/wildfly-10.0.0.Final/modules/org/postgres/main
 ADD content/postgresql-9.3-1102.jdbc41.jar /opt/wildfly-10.0.0.Final/modules/org/postgres/main
 ADD content/postgresql-9.3-1102.jdbc41.jar.index /opt/wildfly-10.0.0.Final/modules/org/postgres/main
 ADD content/standalone.conf /opt/wildfly-10.0.0.Final/bin
  RUN   mkdir /usr/share/fonts
 RUN   mkdir /usr/share/fonts/truetrype
ADD content/Fonts /usr/share/fonts/truetrype
# RUN fc-cache -f

# Expose the ports we're interested in
EXPOSE 8080 8443 9990 8100
 
VOLUME ["/tmp"]

RUN chmod +x /usr/bin/libreoffice_iniciar.sh

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD  ["/usr/bin/libreoffice_iniciar.sh"]

#rodar o comando: docker run --name jbossdt -v ~/docker_volumes/jbossdt:/opt/wildfly-10.0.0.Final/standalone -p 8080:8080 jboss