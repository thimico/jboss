FROM thimico/jre7
MAINTAINER thimico
ENV JBOSS_HOME /opt/jboss-as-7.1.1.Final
WORKDIR /build
RUN mkdir -p /opt \
 && wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz \
 && tar -zxf jboss-as-7.1.1.Final.tar.gz -C /opt \
 && rm -rf /build
 ADD content/selodigital.txt /opt/jboss-as-7.1.1.Final
 RUN mkdir -p /opt/jboss-as-7.1.1.Final/modules/org/postgres/main/mod
 ADD content/module.xml /opt/jboss-as-7.1.1.Final/modules/org/postgres/main
 ADD content/postgresql-9.3-1102.jdbc41.jar /opt/jboss-as-7.1.1.Final/modules/org/postgres/main
 ADD content/postgresql-9.3-1102.jdbc41.jar.index /opt/jboss-as-7.1.1.Final/modules/org/postgres/main
 ADD content/standalone.conf /opt/jboss-as-7.1.1.Final/bin
EXPOSE 8080 8443 9990
CMD ["/opt/jboss-as-7.1.1.Final/bin/standalone.sh", "-b", "0.0.0.0"]