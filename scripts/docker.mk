define DOCKERFILE_DOCKERHUB
FROM scratch
ARG BINARY
ADD $$BINARY /
ENTRYPOINT [ "/rtsp-simple-server" ]
endef
export DOCKERFILE_DOCKERHUB

docker:
	docker buildx rm builder 2>/dev/null || true
	rm -rf $$HOME/.docker/manifests/*
	docker buildx create --name=builder --use

	echo "$$DOCKERFILE_DOCKERHUB" | docker build . -f - \
	--platform=linux/amd64 \
	--build-arg BINARY="$$(echo binaries/*linux_amd64.tar.gz)" \
	-t "echowatch.rtsp"

	docker buildx rm builder
	rm -rf $$HOME/.docker/manifests/*
