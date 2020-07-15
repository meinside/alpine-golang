# alpine-golang

Docker image for go development.

Builds Go 1.4 from the source, then builds latest Go again with it.

It can be used as a base for minimal Go application images.

## How to use

### On x64 Linux

Use tags named `N.N.N-x64` or `latest`.

### On Raspberry Pi 3/3+/4 (ARM32v7)

Use tags named `N.N.N-armv7` or `latest`.

### Build images with a new Dockerfile

Inside your Go application's source directory, create a `Dockerfile` with following content:

```
FROM meinside/alpine-golang:latest AS builder

# Add unprivileged user/group
RUN mkdir /user && \
	echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
	echo 'nobody:x:65534:' > /user/group

# Install certs, git, and mercurial
RUN apk add --no-cache ca-certificates git mercurial

# Working directory outside $GOPATH
WORKDIR /src

# Copy go module files and download dependencies
COPY ./go.mod ./go.sum ./
RUN go mod download

# Copy source files
COPY ./ ./

# Build source files statically
RUN CGO_ENABLED=0 go build \
	-installsuffix 'static' \
	-o /app \
	.

# Minimal image for running the application
FROM scratch as final

# Copy files from temporary image
COPY --from=builder /user/group /user/passwd /etc/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app /

# Open ports (if needed)
#EXPOSE 8080
#EXPOSE 80
#EXPOSE 443

# Will run as unprivileged user/group
USER nobody:nobody

# Entry point for the built application
ENTRYPOINT ["/app"]
```

and build an image with it:

```bash
$ docker build -t IMAGE-NAME .
```

Then you'll get a minimal docker image which runs your Go application.

You can run the image with:

```bash
$ docker run IMAGE-NAME
```

## Build

Build manually with `Dockerfile`:

```bash
$ docker build --pull --no-cache -t TAG_NAME .
```

or build specific version of Go with:

```bash
$ docker build --pull --no-cache -t TAG_NAME --build-arg GO_VERSION=1.12 .
```

### Dockerfile.armhf and Dockerfile.aarch64

I could not build Go 1.4 for armv7 and arm64 successfully on Docker Hub's automated build system.

So these Dockerfiles build latest Go with package manager's version of Go.


For building them manually:

```
# armhf (arm/v7)
$ docker build --pull --no-cache -t meinside/alpine-golang:TAG-armv7 -f Dockerfile.armhf .
$ docker push meinside/alpine-golang:TAG-armv7

# aarch64 (arm64/v8)
$ docker build --pull --no-cache -t meinside/alpine-golang:TAG-arm64v8 -f Dockerfile.aarch64 .
$ docker push meinside/alpine-golang:TAG-arm64v8
```

## Automated Build Rules on Docker Hub

- Tag (/^v([0-9.]+)$/) => {\1}-x64 (Dockerfile)
- Tag (/^v([0-9.]+)$/) => {\1}-arm64v8 (Dockerfile.aarch64)
- Tag (/^v([0-9.]+)$/) => {\1}-armv7 (Dockerfile.armhf)

