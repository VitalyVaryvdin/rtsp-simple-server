define DOCKERFILE_BINARIES
FROM $(BASE_IMAGE)
RUN apk add --no-cache zip make git tar
WORKDIR /s
COPY go.mod go.sum ./
RUN go mod download
COPY . ./

ENV VERSION main
ENV CGO_ENABLED 0
RUN rm -rf binaries
RUN mkdir tmp binaries
RUN cp rtsp-simple-server.yml LICENSE tmp/

RUN GOOS=linux GOARCH=amd64 go build -buildvcs=false -ldflags "-X github.com/aler9/rtsp-simple-server/internal/core.version=$$VERSION" -o tmp/rtsp-simple-server
RUN tar -C tmp -czf binaries/rtsp-simple-server_$${VERSION}_linux_amd64.tar.gz --owner=0 --group=0 rtsp-simple-server rtsp-simple-server.yml LICENSE
endef
export DOCKERFILE_BINARIES

binaries:
	echo "$$DOCKERFILE_BINARIES" | DOCKER_BUILDKIT=1 docker build . -f - -t temp
	docker run --rm -v $(PWD):/out \
	temp sh -c "rm -rf /out/binaries && cp -r /s/binaries /out/"
