FROM openfaas/of-watchdog:0.7.2 as watchdog

FROM rust:1.40-slim as builder

WORKDIR /home/rust

# Copy all the sources
COPY function ./function
COPY main ./main

# FROM alpine:3.11 as runner

# Install packages and add non-root user
RUN apt-get update -qy \
    && apt-get install -qy curl ca-certificates libssl-dev pkg-config
# RUN addgroup -S app && adduser -S -g app app

RUN cd main && cargo build --release

# ENV USER=app

# Copy of-watchdog binary
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Set up watchdog for HTTP mode
ENV fprocess="./main"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:3000"

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
