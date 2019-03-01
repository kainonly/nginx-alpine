## Nginx-Alpine

Nginx's custom image

Docker Pull Command

```shell
docker pull kainonly/nginx-alpine:1.15.9
```

Set docker-compose

```yaml
version: '3.7'
services:
  nginx:
    image: kainonly/nginx-alpine:1.15.9
    restart: always
    volumes:
      - ./nginx/vhost:/etc/nginx/vhost
      - ./nginx/log:/var/nginx
      - ./website:/website
    ports:
      - 80:80
      - 443:443
```

volumes

- `/etc/nginx/vhost` Virtual domain name setting directory
- `/var/nginx` Nginx's log
- `/website` Virtual directory
