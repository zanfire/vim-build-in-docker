# build-in-docker.vim

Plugin focused on help build cool stuff inside a docker container.

## Installation

This plugin support pathogen and should work with other similar plugins.

```
cd ~/.vim/bundle
git clone https://github.com/zanfire/vim-build-in-docker
```

## Requirements

Vim 8.0 and highly raccomanded with asyncrun.

## Globals variable

```
g:build_in_docker_add_hosts='test1.org:192.168.0.1 test2.org:192.168.0.2'
g:build_in_docker_volumes='/opt/custom1:/opt/custom1 /var/log/custom:/var/log/custom'
```

## Command

### RunInDocker

Run a command in a container

```
:RunInDocker container1 make\ -C\ build
```

## BETA VERSION

This is a early beta version developed and tested only on Linux.
