# alpine-golang

Docker image for go development.

Builds go 1.4 from the source, then builds latest go again with it.

It can be used as a base for minimal go application images.

## How to use

### On x64 Linux

Use tags named `N.N.N-x64` or `latest`.

### On Raspberry Pi 3/3+ (ARM32v7)

Use tags named `N.N.N-armv7` or `latest`.

### Build images with a new Dockerfile

Inside your go application's source directory, create a `Dockerfile` with following content:

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

Then you'll get a minimal image that runs your go application.

You can run the image with:

```bash
$ docker run IMAGE-NAME
```

## Build

Build with `Dockerfile`:

```bash
$ docker build -t TAG_NAME .
```

or build specific version of go:

```bash
$ docker build -t TAG_NAME --build-arg GO_VERSION=1.12 .
```

### Dockerfile.arm

Docker Hub's automated build doesn't work well for me, (`qemu-arm-static` problem?)

so I had to build and push it manually on my Raspberry Pi with:

```
$ docker build -t meinside/alpine-golang:TAG-armv7 -f Dockerfile.arm .
$ docker push meinside/alpine-golang:TAG-armv7
```

