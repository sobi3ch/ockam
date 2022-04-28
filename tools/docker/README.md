
From the root directory of the ockam codebase:

## Base

- This image has things all container images will need - entrypoint, locales, curl.
- It is based on a lightweight version of [Debian](https://hub.docker.com/_/debian).
- It has no build tools.
- It is designed to be the base of images that are running in production and don’t need build tools.

Build the base:

```
docker build \
  --build-arg BASE_IMAGE=debian:11.1-slim@sha256:312218c8dae688bae4e9d12926704fa9af6f7307a6edb4f66e479702a9af5a0c \
  --tag ockam/base:latest \
  --tag ghcr.io/ockam-network/ockam/base:latest \
  tools/docker/base
```

## Builder Base

- This image uses the same dockerfile as `ockam/base`.
- It uses a base image of gcc which pulls in most build tools.
- This image is intended for any image that needs a compiler etc.

Build the base_builder:

```
docker build \
  --build-arg BASE_IMAGE=gcc:11.2.0@sha256:04582e63d008aaca294965f075669226f5f74d744f38904f1ad0f00a9590a6e0 \
  --tag ockam/builder_base:latest \
  --tag ghcr.io/ockam-network/ockam/builder_base:latest \
  tools/docker/base
```

## Builder

- This image is based on ockam/builder_base and installs the actual tools needed to build the `/ockam` code base.

Build the builder:

```
docker build \
  --tag ockam/builder:latest \
  --tag ghcr.io/ockam-network/ockam/builder:latest \
  tools/docker/builder
```

Run the builder:

```
docker run --rm -it -e HOST_USER_ID=$(id -u) --volume $(pwd):/work ockam/builder:latest bash
```

## Hub

```
docker build \
  --tag ockam/hub:latest \
  --tag ghcr.io/ockam-network/ockam/hub:latest \
  --file tools/docker/hub/Dockerfile .
```

Run the hub:

```
docker run --rm -it ockam/hub:latest
```
