# syntax=docker/dockerfile:1
# TODO optimize dockerfile with building static binary in CI, OR modcache, etc.
# TODO https://medium.com/@kelseyhightower/optimizing-docker-images-for-static-binaries-b5696e26eb07
FROM golang:1.22 AS build-stage
LABEL authors="andrewsirenko"

# Create a directory inside image I'm building. Also instructs Docker to use this directory as the default.
WORKDIR /app

# Copy into your project directory /app which, the current directory (./) inside the image.
COPY go.mod go.sum ./
RUN go mod download

# Copy rest of files
COPY . .

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o /rest ./cmd/api

# Deploy the application binary into a lean image
FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage  /rest  /rest

# Expost port to correct port
EXPOSE 4000

USER nonroot:nonroot

ENTRYPOINT ["/rest"]