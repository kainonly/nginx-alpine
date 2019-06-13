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

```yaml
version: '3.7'
services:
  nginx:
    image: kainonly/nginx-alpine
    restart: always
    privileged: true
    sysctls:
      net.ipv4.ip_forward: 0
      net.ipv4.conf.default.rp_filter: 1
      net.ipv4.conf.default.accept_source_route: 0
      net.ipv4.tcp_syncookies: 1
      kernel.msgmnb: 65536
      kernel.msgmax: 65536
      kernel.shmmax: 68719476736
      kernel.shmall: 4294967296
      net.core.somaxconn: 40960
      net.ipv4.tcp_synack_retries: 1
      net.ipv4.tcp_syn_retries: 1
      net.ipv4.tcp_fin_timeout: 1
      net.ipv4.tcp_keepalive_time: 30
      net.ipv4.ip_local_port_range: 1024 65000
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/vhost:/etc/nginx/vhost
      - ./nginx/logs:/var/nginx
    ports:
      - 80:80
      - 443:443
```

## Volumes

- `/etc/nginx/nginx.conf` nginx.conf
- `/etc/nginx/vhost` Virtual
- `/var/nginx` Nginx Var

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
    error_log /var/nginx/error.log info;
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

    proxy_connect_timeout 5;
    proxy_read_timeout 60;
    proxy_send_timeout 5;
    proxy_buffering off;
    proxy_buffer_size 128k;
    proxy_buffers 100 128k;
    proxy_busy_buffers_size 256k;
    proxy_temp_file_write_size 128k;

    client_body_temp_path /var/nginx/client_temp;
    proxy_temp_path       /var/nginx/proxy_temp;
    fastcgi_temp_path     /var/nginx/fastcgi_temp;
    uwsgi_temp_path       /var/nginx/uwsgi_temp;
    scgi_temp_path        /var/nginx/scgi_temp;

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
	 
	http2_body_preread_size 128k;
	http2_chunk_size 16k;
	ssl_certificate vhost/developer.com/site.crt;
	ssl_certificate_key vhost/developer.com/site.key;
	ssl_session_cache shared:SSL:20m;
	ssl_session_timeout 10m;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
	ssl_prefer_server_ciphers on;
	ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;
	 
	location / {
		aio threads=default;
		proxy_pass http://10.0.75.1:3000/;
		proxy_redirect    off;
		proxy_set_header  X-Forwarded-For $remote_addr;
	}

	location ~* .(jpg|jpeg|png|gif|ico|css|js)$ {
		expires 365d;
	}
}
```