FROM quay.io/ser_sensini/theredcode:nginx

ENV NAME=nginx \
    NGINX_EXTRA_CONF=/etc/nginx/conf.d \
    NGINX_CONF=/etc/nginx \
    NGINX_HTML=/usr/share/nginx/html \
    NGINX_LOG=/var/log/nginx \
    NGINX_CACHE=/var/cache/nginx \
    LOG_LEVEL=info

COPY . /usr/share/nginx/html

COPY nginx.conf.patch /tmp/
RUN set -eux; \
    echo "===> Updating nginx conf for redirect logs on stdout"; \
    # LOG_LEVEL:  warn, error crit, alert, emerg
    sed -i "/access_log/s%\/.*$%/dev/stdout main;%" ${NGINX_CONF}/nginx.conf; \
    sed -i "/error_log/s%\/.*$%/dev/stderr ${LOG_LEVEL:-info};%" ${NGINX_CONF}/nginx.conf; \
    echo "===> Preparing nginx for running as no root user"; \
    sed -i '/listen/s%80%8080%' ${NGINX_EXTRA_CONF}/default.conf; \
    sed -i 's/^user *nginx;//' ${NGINX_CONF}/nginx.conf; \
    sed -i 's/^user *nginx;//' ${NGINX_EXTRA_CONF}/default.conf; \
    # ADD before match
    sed -i '/location \/ {/i\    location /stub_status {\n        stub_status;\n    }\n' ${NGINX_EXTRA_CONF}/default.conf; \
    # ADD after match
    sed -i '/server_name/a\    absolute_redirect off;' ${NGINX_EXTRA_CONF}/default.conf;

RUN chown -R 1001:0 /usr/share/nginx/html; \
	chown -R 1001:0 ${NGINX_CACHE} ${NGINX_CONF} ${NGINX_HTML} ${NGINX_LOG}; \
	chmod -R g+rwX ${NGINX_CACHE} ${NGINX_EXTRA_CONF} ${NGINX_HTML} ${NGINX_LOG} /var/run; \
    chmod g+rw ${NGINX_CONF}; \
	echo "===> Removing the logs with wrong rights"; \
    rm -rf ${NGINX_LOG}/*.log

USER 1001
