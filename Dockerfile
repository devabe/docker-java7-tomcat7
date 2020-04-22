FROM inovatrend/java7

MAINTAINER Abe <contact@tafatek.com>

ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 7.0.88
ENV MAVEN_MAJOR_VERSION 3
ENV MAVEN_VERSION 3.6.2
ENV CATALINA_HOME /opt/tomcat
ENV MAVEN_HOME /opt/maven
ENV JAVA_OPTS "-Xms1024m -Xmx4096m -XX:PermSize=128m -Xss10m"

RUN apt-get update && \
    apt-get install -yq --no-install-recommends pwgen ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# Install tomcat
RUN \
    wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
#    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* ${CATALINA_HOME}

# Add script for creating tomcat admin user and starting tomcat
ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh

# Add script for starting tomcat as runit service
RUN mkdir /etc/service/tomcat
ADD tomcat.sh /etc/service/tomcat/run
RUN chmod +x /etc/service/tomcat/run

# Add tomcat roles and users
#ADD tomcat-users.xml ${CATALINA_HOME}/conf/

# Remove unneeded apps
RUN rm -rf ${CATALINA_HOME}/webapps/examples ${CATALINA_HOME}/webapps/docs 

# Enabling the insecure key permanently, to be able to login to container using ssh, or docker-ssh
RUN /usr/sbin/enable_insecure_key

# Add navgraph directory
RUN mkdir /usr/navgraph

ENV PATH $PATH:$CATALINA_HOME/bin

# get maven ${MAVEN_VERSION}
RUN wget --no-verbose -O /tmp/apache-maven-${MAVEN_VERSION}.tar.gz http://archive.apache.org/dist/maven/maven-${MAVEN_MAJOR_VERSION}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
# install maven
RUN tar xzf /tmp/apache-maven-${MAVEN_VERSION}.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-${MAVEN_VERSION}.tar.gz
RUN mkdir /root/.m2
ADD settings.xml /root/.m2/settings.xml

RUN mvn -version

RUN  cd /tmp  && \
     echo -n | \
          openssl s_client -prexit -connect tools.tafatek.com:6834 2>&1 | \
          openssl x509 -outform pem \
          > certificate-tools-tafatek-com.pem && \
     keytool -import \
                -alias tools-tafatek-com \
                -file certificate-tools-tafatek-com.pem \
                -keystore $JAVA_HOME/jre/lib/security/cacerts \
                -storepass changeit \
                -noprompt

# remove download archive files
RUN apt-get clean

EXPOSE 8893
EXPOSE 5235

