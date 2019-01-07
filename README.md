## Nginx-Alpine

Nginx's minimalist custom image

- size `6.71` mb
- version `1.14.2`

Docker Pull Command

```shell
docker pull kainonly/nginx-alpine
```

Set docker-compose

```yaml
version: '3'
services:
  nginx:
    image: kainonly/nginx-alpine:1.14.2
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