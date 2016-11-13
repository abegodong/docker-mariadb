NAME = mariadb
TAG = 10.0
IMAGE = str360/$(NAME)

.PHONY: all push clean

all: build push

build:
	docker build -t $(IMAGE):$(TAG) --rm --no-cache .
	
push:
	docker push $(IMAGE)
	
clean:
	docker rmi $(IMAGE):$(TAG)

