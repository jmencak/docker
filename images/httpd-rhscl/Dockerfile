# Sample run
# ~~~~~~~~~~
# docker run --name httpd -it --rm -p8080:8080 jmencak/httpd-rhscl
# docker run --name httpd -it --rm -p8443:8443 jmencak/httpd-rhscl

FROM rhscl/httpd-24-rhel7

MAINTAINER Jiri Mencak

#RUN yum localinstall -y https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
# http://mirror.centos.org/centos/7/os/x86_64/Packages/net-tools-2.0-0.22.20131004git.el7.x86_64.rpm

# Adapt configuration.
COPY files/html /opt/rh/httpd24/root/var/www/html

EXPOSE 8080 8443
