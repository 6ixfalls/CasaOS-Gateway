#!/bin/bash

# Before hooks
echo "Running before hooks..."
go generate
go run github.com/google/go-licenses@latest check . --disallowed_types=restricted
go mod tidy

# Set environment variable
export CC=x86_64-linux-gnu-gcc

# Get commit hash and date
commit=$(git rev-parse HEAD)
date=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Set ldflags
ldflags="-X main.commit=$commit -X main.date=$date -s -w -extldflags '-static'"

# Build the binary
GOOS=linux GOARCH=amd64 go build -tags 'musl netgo osusergo' -ldflags "$ldflags" -o build/sysroot/usr/bin/casaos-gateway

# Post hooks
echo "Running post hooks..."
upx --best --lzma -v --no-progress "build/sysroot/usr/bin/casaos-gateway"