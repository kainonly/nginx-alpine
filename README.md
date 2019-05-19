## Nginx Alpine

Quick and Easy Nginx Image

![MicroBadger Size](https://img.shields.io/microbadger/image-size/kainonly/nginx-alpine.svg?style=flat-square)
![MicroBadger Layers](https://img.shields.io/microbadger/layers/kainonly/nginx-alpine.svg?style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/kainonly/nginx-alpine.svg?style=flat-square)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/kainonly/nginx-alpine.svg?style=flat-square)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/kainonly/nginx-alpine.svg?style=flat-square)

```shell
docker pull kainonly/nginx-alpine
```

Set docker-compose

```yaml
version: '3.7'
services:
  nginx:
    image: kainonly/nginx-alpine
    restart: always
    volumes:
      - ./nginx/vhost:/etc/nginx/vhost
      - /var/nginx/log:/var/nginx
      - /website:/website
    ports:
      - 80:80
      - 443:443
```

volumes

- `/etc/nginx/nginx.conf` Main Config
- `/etc/nginx/vhost` Virtual domain name setting directory
- `/var/nginx` Nginx's log
- `/website` Virtual directory
