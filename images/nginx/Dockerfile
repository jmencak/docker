# Sample run
# ~~~~~~~~~~
# docker run -it --rm -p80:8080 jmencak/nginx

FROM scratch
MAINTAINER Jiri Mencak
COPY ./root /

RUN mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx /var/run \
    && chmod 777 /var/cache/nginx /var/run/ \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 8080 8443

CMD ["./docker-entrypoint.sh"]
