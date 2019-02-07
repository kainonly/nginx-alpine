FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf

VOLUME /etc/nginx/vhost /var/log/nginx