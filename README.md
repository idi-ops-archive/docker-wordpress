## WordPress Dockerfile


This repository is used to build [WordPress](https://www.wordpress.org) Docker images.


### Environment Variables

* SERVER_NAME

### Port(s) Exposed

* `8080 TCP`


### Base Docker Image

* [inclusivedesign/php](https://github.com/idi-ops/docker-php/)


### Volumes

* /var/www/wp-content/

### Download

    docker pull inclusivedesign/wordpress


#### Run `wordpress` (WordPress)


```
docker run \
-d \
-p 8081:80 \
--name="wordpress" \
-e "SERVER_NAME=wp.test.org" \
-v $PWD/data:/var/www/wp-content/ \
inclusivedesign/wordpress
```

### Build your own image

The build system takes the wordpress source stored in `data` directory.

    docker build --rm=true -t <your name>/wordpress .
