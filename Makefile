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

all: build

statics-builder: Dockerfile.in
	docker inspect statics-builder >&/dev/null || \
	TZ=$$(cat /etc/timezone) \
	USER_ID=$$(id -u) \
	USER_NAME=$$(id -un) \
	GROUP_ID=$$(id -g) \
	GROUP_NAME=$$(id -gn) \
	envsubst <Dockerfile.in | docker build -t statics-builder -

build: statics-builder
	mkdir -p src output
	docker run -v $$PWD/src:/src -v $$PWD/build.sh:/src/build.sh -v $$PWD/output:/output statics-builder ./build.sh

clean:
	rm -rf src/*/
	rm -rf output/

cleanall:
	rm -rf src/ output/
