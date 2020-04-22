# Tomcat 7 on Java 7

This image includes Tomcat 7 installation and deployment. It is based on [inovatrend/java7](https://registry.hub.docker.com/u/inovatrend/java7/) , check there what else is installed on it.

Tomcat runs as [runit](http://smarden.org/runit/) service. It is installed in /opt/tomcat dir, and includes Tomcat Manager for deployment of webapps.

To access Tomcat Manager:

 * Username: admin
 * Password: can be set when running docker container by passing TOMCAT_PASS env. veriable. Otherwise random password is generated on startup.

Password can be seen using command:

```sh
docker logs <container_id>
```

In log entry similar to this will appear:

```sh
========================================================================
You can now configure to this Tomcat server using:

    admin:6dD6x4f4IVKT

========================================================================
```

### Pulling image

A prebuilt container is available on Docker Hub, you can get it with following command

```sh
docker pull abecha/tomcat7-jdk7:tagname
```
