# Nginx Alpine

Quick and Easy Nginx Image

![MicroBadger Size](https://img.shields.io/microbadger/image-size/kainonly/nginx-alpine.svg?style=flat-square)
![MicroBadger Layers](https://img.shields.io/microbadger/layers/kainonly/nginx-alpine.svg?style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/kainonly/nginx-alpine.svg?style=flat-square)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/kainonly/nginx-alpine.svg?style=flat-square)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/kainonly/nginx-alpine.svg?style=flat-square)

```shell
docker pull kainonly/nginx-alpine
```

## Docker Compose

```yml
version: '3.7'
services:
  nginx:
    image: kainonly/nginx-alpine
    restart: always
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/vhost:/etc/nginx/vhost
      - ./nginx/log:/var/log/nginx
      - ./nginx/cache:/var/cache/nginx
      - ./run:/var/run
      - /website:/website
    ports:
      - 80:80
      - 443:443
```

## Volumes

- `/etc/nginx/nginx.conf` Default nginx.conf
- `/etc/nginx/vhost` Virtual directory sub-configuration file
- `/var/log/nginx` Log directory
- `/var/cache/nginx` Cache directory
- `/var/run` nginx.pid and nginx.lock

## Default nginx.conf

```conf
user nginx nginx;

# worker_processes 8;
# worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;
worker_processes auto;
worker_rlimit_nofile 65535;

pid /var/run/nginx.pid;
lock_file /var/run/nginx.lock;
# thread_pool default threads=16;

events {
  use epoll;
  worker_connections 65535; 
  accept_mutex off;
  multi_accept off;
}

http {
  charset utf-8;
  include mime.types;
  default_type application/octet-stream;

  log_format main $remote_addr - $remote_user [$time_local] "$request"  $status $body_bytes_sent "$http_referer"  "$http_user_agent" "$http_x_forwarded_for";
  error_log /var/log/nginx/error.log info;
  access_log off;

  server_tokens off;
  server_names_hash_bucket_size 128;
  server_names_hash_max_size 512;

  client_body_buffer_size 10K;
  client_header_buffer_size 4k;
  client_max_body_size 16m;

  keepalive_timeout 60 50;
  send_timeout 60s;

  open_file_cache max=65535 inactive=60s;
  open_file_cache_valid 80s;
  open_file_cache_min_uses 1;

  aio on;
  sendfile on; 
  sendfile_max_chunk 512k;
  directio 8m;

  tcp_nopush on;
  tcp_nodelay on;

  gzip on; 
  gzip_disable "MSIE [1-6].(?!.*SV1)";
  gzip_http_version 1.1;
  gzip_vary on;
  gzip_proxied any;
  gzip_min_length 1k;
  gzip_buffers 32 4k;
  gzip_comp_level 2;
  gzip_types text/plain text/css text/javascript application/json;

  brotli_static on;
  brotli on;
  brotli_types text/plain text/css text/javascript application/json;

  proxy_connect_timeout 5;
  proxy_read_timeout 60;
  proxy_send_timeout 5;
  proxy_buffering off;
  proxy_buffer_size 128k;
  proxy_buffers 100 128k;
  proxy_busy_buffers_size 256k;
  proxy_temp_file_write_size 128k;

  client_body_temp_path /var/cache/nginx/client_temp;
  proxy_temp_path       /var/cache/nginx/proxy_temp;
  fastcgi_temp_path     /var/cache/nginx/fastcgi_temp;
  uwsgi_temp_path       /var/cache/nginx/uwsgi_temp;
  scgi_temp_path        /var/cache/nginx/scgi_temp;

  server {
    listen 80 default;
    return 404;
  }

  include vhost/**/*.conf;
}
```

## Example Virtual

create `./nginx/vhost/developer.com/site.conf`

```conf
server {
  listen  80;
  server_name developer.com;
  rewrite ^(.*)$  https://$host$1 permanent;
}

server {
  listen 443 ssl http2;
  server_name developer.com;

  add_header X-Frame-Options "SAMEORIGIN";
  add_header X-XSS-Protection "1; mode=block";
  add_header X-Content-Type-Options "nosniff";

  ssl_certificate vhost/developer.com/site.crt;
  ssl_certificate_key vhost/developer.com/site.key;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;
  ssl_early_data on;

  location / {
    try_files $uri $uri/ /index.php?$query_string;
    aio threads=default;
  }

  location = /favicon.ico { access_log off; log_not_found off; }
  location = /robots.txt  { access_log off; log_not_found off; }

  location ~ /\.(?!well-known).* {
    deny all;
  }

  location ~* .(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 365d;
  } 

  error_page 404 /index.php;

  location ~ \.php$ {
    fastcgi_pass unix:/var/run/php-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    include fastcgi_params;
  }
}
```