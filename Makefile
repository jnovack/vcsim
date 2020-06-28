PARENT := "vmware/govmomi"
APPLICATION := $(shell basename `pwd`)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BUILD_RFC3339 := $(shell date -u +"%Y-%m-%dT%H:%M:%S+00:00")
COMMIT := $(shell curl -s https://api.github.com/repos/${PARENT}/tags \
    | grep '"sha".*[a-z0-9]' \
    | head -n 1 \
	| cut -d '"' -f 4 \
	| cut -c -9)
DESCRIPTION := $(shell curl -s https://api.github.com/repos/${PARENT} \
    | grep '"description".*' \
    | head -n 1 \
    | cut -d '"' -f 4)
VERSION := $(shell curl -s https://api.github.com/repos/${PARENT}/tags \
    | grep 'name.*v[0-9]' \
    | head -n 1 \
    | cut -d '"' -f 4)

GO_LDFLAGS := "-w -s"

DOCKER_BUILD_ARGS := \
	--build-arg APPLICATION=${APPLICATION} \
	--build-arg BUILD_RFC3339=${BUILD_RFC3339} \
	--build-arg COMMIT=${COMMIT} \
	--build-arg DESCRIPTION=${DESCRIPTION} \
	--build-arg VERSION=${VERSION} \
	--progress auto

all: build

.PHONY: build
build:
	go build -o bin/${APPLICATION} -ldflags $(GO_LDFLAGS)

docker:
	docker build ${DOCKER_BUILD_ARGS} -t ${APPLICATION}:${BRANCH} .
