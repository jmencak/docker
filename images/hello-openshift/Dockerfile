# A simple web application with busybox root.
#
# Sample run
# ~~~~~~~~~~
# docker run -it --rm jmencak/hello-openshift /bin/sh

FROM scratch
MAINTAINER Jiri Mencak
COPY ./hello-root /
COPY hello-openshift /usr/local/bin/hello-openshift
EXPOSE 8080 8888
CMD ["/usr/local/bin/hello-openshift"]
