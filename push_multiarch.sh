#!/bin/bash
#
# Create manifests for multiarch support
#
# Put
#	"experimental":"enabled"
# in ~/.docker/config.json
#
#
# last update: 2020.07.15.

# get latest version from tags (without prefix 'v')
VERSION=`echo $(git describe --tags $(git rev-list --tags --max-count=1)) | tr -d "v"`

# delete existing manifest
docker image rm -f meinside/alpine-golang:$VERSION
docker image rm -f meinside/alpine-golang:latest

# create manifest for given version
docker manifest create meinside/alpine-golang:$VERSION \
	meinside/alpine-golang:$VERSION-x64 \
	meinside/alpine-golang:$VERSION-armv7 \
	meinside/alpine-golang:$VERSION-arm64v8
docker manifest create meinside/alpine-golang:latest \
	meinside/alpine-golang:$VERSION-x64 \
	meinside/alpine-golang:$VERSION-armv7 \
	meinside/alpine-golang:$VERSION-arm64v8

# annotation for x64 (amd64)
docker manifest annotate meinside/alpine-golang:$VERSION \
	meinside/alpine-golang:$VERSION-x64 \
	--os linux --arch amd64
docker manifest annotate meinside/alpine-golang:latest \
	meinside/alpine-golang:$VERSION-x64 \
	--os linux --arch amd64

# annotation for armhf (arm/v7)
docker manifest annotate meinside/alpine-golang:$VERSION \
	meinside/alpine-golang:$VERSION-armv7 \
	--os linux --arch arm --variant v7
docker manifest annotate meinside/alpine-golang:latest \
	meinside/alpine-golang:$VERSION-armv7 \
	--os linux --arch arm --variant v7

# annotation for aarch64 (arm64/v8)
docker manifest annotate meinside/alpine-golang:$VERSION \
	meinside/alpine-golang:$VERSION-arm64v8 \
	--os linux --arch arm64 --variant v8
docker manifest annotate meinside/alpine-golang:latest \
	meinside/alpine-golang:$VERSION-arm64v8 \
	--os linux --arch arm64 --variant v8

# push manifest
docker manifest push -p meinside/alpine-golang:$VERSION
docker manifest push -p meinside/alpine-golang:latest

