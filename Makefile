.SUFFIXES:
MAKEFLAGS += -r
SHELL := /bin/bash
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# do not leave failed files around
.DELETE_ON_ERROR:
# do not delete intermediate files
#.SECONDARY:
# fake targets
.PHONY: all statics-builder build clean cleanall

DOCKER_IP = $(shell ifconfig docker0 | grep -o 'inet addr:[0-9.]*' | cut -d: -f2)
PROXY_PORT = 3128
INET_PROXY = $(shell nc -zw1 ${DOCKER_IP} ${PROXY_PORT} && echo "http://${DOCKER_IP}:${PROXY_PORT}")

all: build

statics-builder: Dockerfile.in
	docker inspect statics-builder >&/dev/null || \
	TZ=$$(cat /etc/timezone) \
	USER_ID=$$(id -u) \
	USER_NAME=$$(id -un) \
	GROUP_ID=$$(id -g) \
	GROUP_NAME=$$(id -gn) \
	INET_PROXY=${INET_PROXY} \
	envsubst <Dockerfile.in | cat #docker build -t statics-builder -

build: statics-builder
	mkdir -p src output
	docker run --rm -v $$PWD/src:/src -v $$PWD/build.sh:/src/build.sh -v $$PWD/output:/output statics-builder ./build.sh

clean:
	rm -rf src/*/ # keep sources
	rm -rf output/

cleanall:
	rm -rf src/ output/
	docker rmi statics-builder
