# Dockerfile for Alpine Linux with Golang
#
# created: 2018.11.08.
# updated: 2019.12.06.
#
# referenced: https://github.com/meinside/rpi-configs/blob/master/bin/install_go.sh

# https://hub.docker.com/_/alpine/
FROM alpine:3.10

LABEL maintainer="meinside@gmail.com"

# build argument
ARG GO_VERSION="1.13.5"

# target go version
ENV go_version="$GO_VERSION" \
	bootstrap_go_version="1.4"

# other variables
ENV go_repository="https://go.googlesource.com/go" \
	bootstrap_go_branch="release-branch.go$bootstrap_go_version" \
	bootstrap_go_dir="/go1.4" \
	go_branch="go$go_version" \
	go_dir="/go-$go_version"

# install packages,
# clone bootstrap go (1.4) repository,
# build bootstrap go (1.4),
# build go with bootstrap go,
# then remove unneeded files
RUN apk add --no-cache bash git gcc libc-dev linux-headers && \
	git clone -b $bootstrap_go_branch $go_repository $bootstrap_go_dir && \
	cd $bootstrap_go_dir/src && \
	./make.bash && \
	git clone -b $go_branch $go_repository $go_dir && \
	cd $go_dir/src && \
	GOROOT_BOOTSTRAP=$bootstrap_go_dir ./make.bash && \
	rm -rf $bootstrap_go_dir && \
	rm -rf $go_dir/.git $go_dir/pkg/obj $go_dir/pkg/bootstrap && \
	mkdir /go

# set PATH, GOROOT and GOPATH
ENV GOROOT="$go_dir" \
	GOPATH="/go" \
	PATH="$PATH:$go_dir/bin"

# check disk usage
#RUN du -h -d 1 /

# show version
RUN go version

# default command
CMD ["bash"]

