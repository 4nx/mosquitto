# Eclipse Mosquitto MQTT Docker Container

Table of Contents
=================

   * [Eclipse Mosquitto MQTT Docker Container](#mosquitto-docker-container)
      * [Introduction](#introduction)
      * [Image Variants](#image-variants)
      * [Usage](#usage)
         * [Starting with Docker named volumes](#starting-with-docker-named-volumes)
            * [Running from command line](#running-from-command-line)
            * [Running from compose-file.yml](#running-from-compose-fileyml)
         * [Accessing the console](#accessing-the-console)
      * [Environment variables](#environment-variables)
      * [Parameters](#parameters)
      * [Building the image](#building-the-image)
      * [License](#license)

## Introduction

This repository is for building a Docker container with Eclispe Mosquitto MQTT daemon under Alpine Linux. Comments, suggestions and contributions are welcome! 

## Image Variants

``4nx/mosquitto:<mosquitto-version>``

**Version**

* [``1.4.15-r0`` Stable mosquitto 1.4.15-r0 version](https://github.com/4nx/mosquitto/Dockerfile)

**Architecture:**

* ``amd64`` for most desktop computer (e.g. x64, x86-64, x86_64)

**Distributions:**

* ``alpine`` for alpine 3.7

## Usage

The following methods to use the container are available:

### Starting with Docker named volumes

The following three mount points have been created in the image. These volumes will survive, if you delete or upgrade your container:

```
/opt/mosquitto/config
/opt/mosquitto/data
/opt/mosquitto/log
```

So you should create similar folders on your host system, e.g.:

mkdir -p /home/mosquitto/{config,data,log}

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
TBD
```

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

* You create the same user with the same uid and gid on your docker host system
```
groupadd -g 101 mosquitto
useradd -u 100 -g mosquitto -r -s /sbin/nologin mosquitto
usermod -a -G mosquitto your-user (optional)
```

* Or you will choose another user to run the docker container AND passing the uid and gid to mosquitto through env
```
docker run \
(...)
--user <your-uid> \
-e USER_ID=<your-uid>
-e GROUP_ID=<your-gid>
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

## License

When not explicitly set, files are placed under [![Eclipse license](https://img.shields.io/badge/license-Eclipse-blue.svg)](https://github.com/4nx/mosquitto/blob/master/LICENSE).

## Acknowledgement

Inspiration and README.md snipplets came from [openHAB](https://github.com/openhab/openhab-docker) project, specificaly from their Docker containers, because I am using them together.
The image based on the work of the [eclipse-mosquitto](https://github.com/eclipse/mosquitto) project and their docker container.
