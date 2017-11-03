# Sample run
# ~~~~~~~~~~
# docker run -it --rm jmencak/mb

FROM centos:7

MAINTAINER Jiri Mencak

RUN yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflags=nodocs install bc gcc git gnuplot go make \
                   openssh-clients rsync tar && \
    mkdir -p build && cd build && \
    git clone https://github.com/openshift/svt.git && \
      cd svt/utils/pctl && go build pctl.go && cp pctl /usr/local/bin && cd ../../.. && \
    git clone https://github.com/jmencak/mb.git && \
      cd mb && git checkout tags/v0.1.3 -b build && make && cp ./mb /usr/local/bin && cd .. && \
    cd && rm -rf build && \
    yum -y remove gcc go make && \
    yum clean all

COPY ./root/ /root
WORKDIR /root

CMD ["./docker-entrypoint.sh"]
