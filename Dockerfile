FROM quay.io/ser_sensini/theredcode:nginx

ENV NAME=nginx \
    NGINX_EXTRA_CONF=/etc/nginx/conf.d \
    NGINX_CONF=/etc/nginx \
    NGINX_HTML=/usr/share/nginx/html \
    NGINX_LOG=/var/log/nginx \
    NGINX_CACHE=/var/cache/nginx \
    LOG_LEVEL=info

COPY . /usr/share/nginx/html

RUN chown -R 1001:0 /usr/share/nginx/html; \
	chown -R 1001:0 ${NGINX_CACHE} ${NGINX_CONF} ${NGINX_HTML} ${NGINX_LOG}; \
	chmod -R g+rwX ${NGINX_CACHE} ${NGINX_EXTRA_CONF} ${NGINX_HTML} ${NGINX_LOG} /var/run; \
    chmod g+rw ${NGINX_CONF}; \
	echo "===> Removing the logs with wrong rights"; \
    rm -rf ${NGINX_LOG}/*.log

USER 1001
