#!/bin/bash
#
# Create manifests for multiarch support
#
# Put
#	"experimental":"enabled"
# in ~/.docker/config.json
#

# get latest version from tags (without prefix 'v')
VERSION=`echo $(git describe --tags $(git rev-list --tags --max-count=1)) | tr -d "v"`

# delete existing manifest
docker image rm -f meinside/alpine-golang:$VERSION
docker image rm -f meinside/alpine-golang:latest

# create manifest for given version
docker manifest create meinside/alpine-golang:$VERSION \
	meinside/alpine-golang:$VERSION-x64 \
	meinside/alpine-golang:$VERSION-armv7
docker manifest create meinside/alpine-golang:latest \
	meinside/alpine-golang:$VERSION-x64 \
	meinside/alpine-golang:$VERSION-armv7

# annotation for x64 (amd64)
docker manifest annotate meinside/alpine-golang:$VERSION \
	meinside/alpine-golang:$VERSION-x64 \
	--os linux --arch amd64
docker manifest annotate meinside/alpine-golang:latest \
	meinside/alpine-golang:$VERSION-x64 \
	--os linux --arch amd64

# annotation for arm32v7 (arm/v7)
docker manifest annotate meinside/alpine-golang:$VERSION \
	meinside/alpine-golang:$VERSION-armv7 \
	--os linux --arch arm --variant v7
docker manifest annotate meinside/alpine-golang:latest \
	meinside/alpine-golang:$VERSION-armv7 \
	--os linux --arch arm --variant v7

# push manifest
docker manifest push -p meinside/alpine-golang:$VERSION
docker manifest push -p meinside/alpine-golang:latest

