.PHONY: build run copy down checksum verify clean package all

BUILD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

VERSION := $(shell git describe --tags)
IMAGE_NAME := ifmqtoggle-builder:$(VERSION)
CONTAINER_NAME := ifmqtoggle-build-$(VERSION)
OPENWRT_RELEASE := v23.05.3

build:
	cd $(shell dirname $(BUILD_DIR)); \
	docker image build --build-arg OPENWRT_RELEASE=$(OPENWRT_RELEASE) -f $(BUILD_DIR)/Dockerfile -t $(IMAGE_NAME) .

run:
	docker container run -d --name $(CONTAINER_NAME) $(IMAGE_NAME) tail -f /dev/null

copy:
	docker container cp $(CONTAINER_NAME):$(shell docker exec $(CONTAINER_NAME) sh -c "readlink -f bin/packages/*/mypackages/ifmqtoggle_*_all.ipk") $(BUILD_DIR)/

down:
	docker container rm -f $(CONTAINER_NAME)

checksum:
	$(eval filepath := $(shell ls $(BUILD_DIR)/ifmqtoggle_*_all.ipk))
	cd $(shell dirname $(filepath)); \
	shasum -a 256 $(shell basename $(filepath)) > $(shell basename $(filepath)).sha256

verify:
	$(eval filepath := $(shell ls $(BUILD_DIR)/ifmqtoggle_*_all.ipk))
	cd $(shell dirname $(filepath)); \
	shasum -a 256 -c $(shell basename $(filepath)).sha256

clean:
	rm -f $(BUILD_DIR)/ifmqtoggle_*_all.ipk
	rm -f $(BUILD_DIR)/ifmqtoggle_*_all.ipk.sha256
	@$(MAKE) -f $(BUILD_DIR)/Makefile down
	docker image rm -f $(IMAGE_NAME)

package: build run copy down
all: package checksum verify

.DEFAULT_GOAL := package
