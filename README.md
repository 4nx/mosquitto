# Eclipse Mosquitto MQTT Docker Container
[![Build Status](https://travis-ci.org/4nx/mosquitto.svg?branch=master)](https://travis-ci.org/4nx/mosquitto) [![](https://images.microbadger.com/badges/version/4nxio/mosquitto:1.4.15-r0.svg)](https://microbadger.com/images/4nxio/mosquitto:1.4.15-r0 "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/4nxio/mosquitto:1.4.15-r0.svg)](https://microbadger.com/images/4nxio/mosquitto:1.4.15-r0 "Get your own image badge on microbadger.com") 

Table of Contents
=================

   * [Eclipse Mosquitto MQTT Docker Container](#mosquitto-docker-container)
      * [Introduction](#introduction)
      * [Image Variants](#image-variants)
      * [Usage](#usage)
         * [Create the mosquitto user](#create-the-mosquitto-user)
         * [Starting with Docker named volumes](#starting-with-docker-named-volumes)
            * [Running from command line](#running-from-command-line)
            * [Running from compose-file.yml](#running-from-compose-fileyml)
         * [Accessing the console](#accessing-the-console)
      * [Environment variables](#environment-variables)
      * [Parameters](#parameters)
      * [Building the image](#building-the-image)
      * [Additional configurations](#additional-configurartions)
         * [Create users](#create-users)
         * [Disable anonymous logins](#disable-anonymour-logins)
      * [License](#license)

## Introduction

This repository is for building a Docker container with Eclispe Mosquitto MQTT daemon under Alpine Linux. Comments, suggestions and contributions are welcome! 

## Image Variants

``4nx/mosquitto:<mosquitto-version>``

**Version**

* [``latest / 1.4.15-r0`` Stable mosquitto 1.4.15-r0 version](https://github.com/4nx/mosquitto/Dockerfile)

**Architecture:**

* ``amd64`` for most desktop computer (e.g. x64, x86-64, x86_64)

**Distributions:**

* ``alpine`` for alpine 3.7

## Usage

The following methods to use the container are available:

### Create the mosquitto user

It is recommended to create an additional user with no home and no shell to run your container:
```
sudo useradd -r -s /sbin/nologin mosquitto
```

You can add you regular user to the group of the mosquitto user:
```
sudo usermod -a -G mosquitto <user>
```

### Starting with Docker named volumes

The following three mount points have been created in the image. These volumes will survive, if you delete or upgrade your container:
```
/opt/mosquitto/config
/opt/mosquitto/data
/opt/mosquitto/log
```

So you should create similar folders on your host system, e.g.:
```
mkdir -p /opt/mosquitto/{config,data,log}
```

and change ownership to our former created mosquitto user:
```
chown -R mosquitto:mosquitto /opt/mosquitto
```

#### Running from command line
```SHELL
docker run \
    --name mosquitto \
    --tty \
    -p 1883:1883 \
    -p 9001:9001 \
    -v /etc/localtime:/etc/localtime:ro \
    -v <path-on-your-system>:/opt/mosquitto/config \
    -v <path-on-your-system>:/opt/mosquitto/data \
    -v <path-on-your-system>:/opt/mosquitto/log \
    -d \
    --restart=always \
    4nx/mosquitto:1.4.15-r0
```

#### Running from compose-file.yml

Create the following ``docker-compose.yml`` and start the container with ``docker-compose up -d``
```YAML
version: '3'
services:
    mosquitto:
        image: "4nxio/mosquitto:1.4.15-r0"
        restart: always
        volumes:
            - "/etc/localtime:/etc/localtime:ro"
            - "/etc/timezone:/etc/timezone:ro"
            - "/opt/container/mosquitto/config:/opt/mosquitto/config"
            - "/opt/container/mosquitto/data:/opt/mosquitto/data"
            - "/opt/container/mosquitto/log:/opt/mosquitto/log"
        ports:
            - "1883:1883"
            - "9001:9001"
        tty: true
        environment:
            USER_ID: "1001"
            GROUP_ID: "1001"
```

With that you will have the docker container started from the automated build image on Docker Hub. You can also build the image by yourself by checking out the Dockerfile, entrypoint.sh and creating the following ``docker-compose.yml``:
```YAML
version: '3'
services:
    mosquitto:
        build: .
        restart: always
        volumes:
            - "/etc/localtime:/etc/localtime:ro"
            - "/etc/timezone:/etc/timezone:ro"
            - "/opt/container/mosquitto/config:/opt/mosquitto/config"
            - "/opt/container/mosquitto/data:/opt/mosquitto/data"
            - "/opt/container/mosquitto/log:/opt/mosquitto/log"
        ports:
            - "1883:1883"
            - "9001:9001"
        tty: true
        environment:
            USER_ID: "1001"
            GROUP_ID: "1001"
```
It will also be started via ``docker-compose up -d``. But be advised that it will be build only the first time. If you want to build it later again use ``docker-compose build`` or ``docker-compose up --build``. You can check that the container is running with ``docker-compose ps``. You can stop the container with ``docker-compose stop`` and remove the images with ``docker-compose rm``. 

#### Configuration of peristent data and logs

After starting the container the first time you will find a configuration file within your <path>/mosquitto/config directory which you created before. Add the following:
```
persistence true
persistence_location /opt/mosquitto/data/
log_dest file /opt/mosquitto/log/mosquitto.log
```

### Accessing the console

You can connect to a console of an already running mosquitto container with following command:
* ``docker ps``  - lists all your currently running container
* ``docker exec -it mosquitto /bin/sh`` - connect to mosquitto container by name
* ``docker logs mosquitto`` - gives you the output of the mosquitto container while starting

## Environment variables

*  `USER_ID`=100
*  `GROUP_ID`=101

### User and group identifiers

By default the mosquitto user in the container is running with:

* `uid=100(mosquitto) gid=101(mosquitto)`

Make sure that either

* You will use the former created user in the beginning AND pass the uid and gid to mosquitto through environments:
```
docker run \
    (...)
    --user <your-uid> \
    -e USER_ID=<mosquitto-uid>
    -e GROUP_ID=<mosquitto-gid>
```    

* or you create the same user with the same uid and gid on your docker host system:
```
groupadd -g 101 mosquitto
useradd -u 100 -g mosquitto -r -s /sbin/nologin mosquitto
usermod -a -G mosquitto your-user (optional)
```

## Parameters

* `-p 1883` - the standard port of mosquitto
* `-p 9001` - the standard tls encrypted port of mosquitto
* `-v /opt/mosquitto/config` - configuration directory
* `-v /opt/mosquitto/data` - persistent data directory
* `-v /opt/mosquitto/log` - log directory

## Building the image

Checkout the github repository and then run these commands:
```
$ docker build -t 4nx/mosquitto:1.4.15-r0 .
```

## Additional configurations

You can configure much more with mosquitto. The following are some examples.

### Create users

Because you haven't have any users to login now you need to create at least one or use anonymous login. To do so you need to use the ``mosquitto_passwd`` command which you can use inside your running container. Get into the console via:
```
docker exec -it $(docker ps | grep mosquitto | cut -d" " -f 1) /bin/sh
```
and create the passwd file with:
```
mosquitto_passwd -c /opt/mosquitto/config/mosquitto.passwd openhab
```
You can also add additional user without the use von ``-c``.

### Disable anonymous logins

By default every client and user can use anonymous login to the MQTT broker and is able to publish and subscribe there. If you do not want this you can disable anonymous logins inside ``/opt/mosquitto/config/mosquitto.conf`` via:
```
allow_anonymous false
```

## License

When not explicitly set, files are placed under [![Eclipse license](https://img.shields.io/badge/license-Eclipse-blue.svg)](https://github.com/4nx/mosquitto/blob/master/LICENSE).

## Acknowledgement

Inspiration and README.md snipplets came from [openHAB](https://github.com/openhab/openhab-docker) project, specificaly from their Docker containers, because I am using them together.
The image based on the work of the [eclipse-mosquitto](https://github.com/eclipse/mosquitto) project and their docker container.
