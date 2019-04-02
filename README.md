# SSH Docker jumpbox

My idea was to build small docker container which will be acting as Linux jumpbox. This project is based on already exiting one https://github.com/warden/docker-jumpbox but it has been rewritten and size of image has been reduced.

Additionally, I wanted to have possibility to have many ssh jumpbox containers on Docker host (or Swarm for redundancy) where each of them will only have access to particular network subnet. This is quite useful in large network environment when we have many teams using one (two) jump hosts to access their separated environments.
This has been achieved by filtering access to network segments using iptables rules on each Docker host.

## Building image
To build docker image clone this repo and run build command. You can add additional packages by editing Dockerfile.
```
$ cd ssh-docker-jumpbox
$ docker build --rm -t ssh-jumpbox .
```
Listing images:
```
$ docker images
REPOSITORY                          TAG                 IMAGE ID            CREATED             SIZE
ssh-jumpbox                         latest              ff4a2f8bdd50        3 days ago          91.9MB
```

## Starting ssh-docker-jumpbox
This is just general guidance and you don't need to follow it step-by-step. You can user your own build image or use mine from Docker Hub.
#### Prepare directories
Create directory where 'authorized_keys' file will be stored. I use '/opt/jumpboxX':
```
$ sudo mkdir -p /opt/jumpbox1
```
#### Create authorized_keys
Each user is authenticated by ssh key during login, and to be able to do it, specially 'crafted' file is required. It's like normal authorized_keys file but with username at the beginning. General file format is:
```
username:ssh_public_key
```
Created file need to be placed in previously created directory:
```
/opt/jumpbox1/authorized_keys
```

#### Create volume
I prefer to use separated volume to store and preserver users local files.
```
$ docker volume create jumpbox1
```

### Starting ssh-jumpbox container on single Docker host
When all previous setups are in place, start container:
```
$ docker run -d --name=jumpbox1 --hostname=jumpbox1 \
    -e USERS="test1 test2" \
    -v /opt/jumpbox1/authorized-keys:/etc/authorized-keys:ro \
    -v jumpbox1:/home \
    -p 1022:22 monsoft/ssh-jumpbox
```
As USERS variable, we passing usernames for which we created corresponding lines in authorized_keys file.
