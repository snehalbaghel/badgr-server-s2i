IMAGE_NAME = badgr-server-s2i

.PHONY: build
build:
	docker build -t $(IMAGE_NAME) .

