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
      * [TLS configuration](#tls-configuration)
         * [One way TLS](#one-way-tls)
            * [Create Certificate Authority](#create-certificate-authority)
            * [Create server certificate](#create-server-certificate)
            * [Sign certificate with your own CA](#sign-certifcate-with-your-own-ca)
            * [Enable TLS configuration](#enable-tls-configuration)
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
* `-p 8883` - the standard tls port of mosquitto: [see TLS configuration](#tls-configuration)
* `-p 9001` - the standard websockets port of mosquitto
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
mosquitto_passwd -c /opt/mosquitto/config/mosquitto.passwd <new-user>
```
You can also add additional user without the use von ``-c``.

To activate the password file it must be added to ``/opt/mosquitto/config/mosquitto.conf`` with:
```
password_file /opt/mosquitto/config/mosquitto.passwd
```
At least change the ownership and access right for this file and restart the container:
```
chown mosquitto:mosquitto /opt/mosquitto/config/mosquitto.passwd
chmod 600 /opt/mosquitto/config/mosquitto.passwd
```

### Disable anonymous logins

By default every client and user can use anonymous login to the MQTT broker and is able to publish and subscribe there. If you do not want this you can disable anonymous logins inside ``/opt/mosquitto/config/mosquitto.conf`` via:
```
allow_anonymous false
```

### Configure access rights for users

You are able to configure access rights for users, which will be done inside a separate file like e.g. ``/opt/mosquitto/config/mosquitto.acl``:
```
user admin
pattern readwrite #

user client
pattern read sensor/data

user server
pattern write sensor/data
```
The example above uses two types of entries. The first one defines the user while the second gives him the access permissions. You are  able to give users read and/or write access to specific pathes by defining them. So in productive environments it makes sense to have different users with different access rights.

To activate the configuration you need to add it into the ``/opt/mosquitto/config/mosquitto.acl`` via:
```
acl_file /opt/mosquitto/config/mosquitto.acl
```

### TLS configuration

In sensitive production environments I recommend to use TLS based transport encryption. But you should be aware that the possibility depends on your IoT infrastructure because some low cost devices may not support MQTT over TLS or their micro controller are not capable to handle the encryption. It also increases the size of the TCP streams which could be relevant for devices where every MegaByte costs money (e.g. mobile connections).

#### One way TLS

The configuration for the server side TLS configuration will be described.

##### Create Certificate Authority

If you do not plan to use your companys CA or a public one like Let's Encrypt, you can create you own certificate authority certificate and key to use them for signing later:
```
openssl req -new -x509 -days 3650 -extensions v3_ca -keyout ca.key -out ca.crt
```
You will be asked for a password which will be used to encrypt the key file and informations like country, city etc. which will be placed in the ca certificate.

##### Create server certificate

You should create the private key on the MQTT broker side with at least 2048 bit (better 4096) via:
```
openssl genrsa -out server.key 2048
```
After that you can generate a certificate signing request ``server.csr`` to send it to a CA or sign it by your own created:
```
openssl req -out server.csr -key server.key -new
```
You will be ask for some informations like country name, city etc. You should use correct common name in FQDN of your MQTT server, like ``mqtt.example.net``.

##### Sign certificate with your own CA

If you don't want to use your own CA, you can sign the former created request with:
```
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 1825
```
A prompt will ask for your ca key password, will sign the request and create the server certificate.

##### Enable TLS configuration

Now you only need to update your ``/opt/mosquitto/config/mosquitto.conf`` to be able to use the TLS certificates:
```
listener 8883
cafile /opt/mosquitto/config/ca.crt
certfile /opt/mosquitto/config/server.crt
keyfile /opt/mosquitto/config/server.key
tls_version tlsv1.2
ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
```
It is recommended to use ``tls_version tlsv1.2`` but if your devices won't support it you can switch to at least ``tls_version tlsv1``. From now on the broker will be accessible only via TCP port 8883. If you want to have TCP 1883 additionally without TLS you can add also:
```
listener 1883
```
Maybe you need to recreate your container to get 8883 active and don't forget to forward it via ``-p 8883:8883`` or:
```
ports:
    - "8883:8883"
    [...]
```
inside ``docker-compose.yml``.

## License

When not explicitly set, files are placed under [![Eclipse license](https://img.shields.io/badge/license-Eclipse-blue.svg)](https://github.com/4nx/mosquitto/blob/master/LICENSE).

## Acknowledgement

Inspiration and README.md snipplets came from [openHAB](https://github.com/openhab/openhab-docker) project, specificaly from their Docker containers, because I am using them together.
The image based on the work of the [eclipse-mosquitto](https://github.com/eclipse/mosquitto) project and their docker container.
