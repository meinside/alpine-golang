# alpine-golang

Docker image for go development.

Builds go from the source.

## How to use

### On x64 Linux

Use tags named `vN.N.N` or `latest`.

Inside your go application's source directory, create a `Dockerfile` with following content:

```
FROM meinside/alpine-golang:latest AS builder

# Add unprivileged user/group
RUN mkdir /user && \
	echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
	echo 'nobody:x:65534:' > /user/group

# Install certs, git, and mercurial
RUN apk add --no-cache ca-certificates mercurial

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
### On Raspberry Pi 3/3+ (ARM32v7)

Use tags named `vN.N.N-arm` or `latest-arm`.

Inside your go application's source directory, create a `Dockerfile` with following content:

```
FROM meinside/alpine-golang:latest-arm AS builder

# Add unprivileged user/group
RUN mkdir /user && \
	echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
	echo 'nobody:x:65534:' > /user/group

# Install certs, git, and mercurial
RUN apk add --no-cache ca-certificates mercurial

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

