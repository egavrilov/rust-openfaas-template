FROM openfaas/of-watchdog:0.7.6 as watchdog

FROM ekidd/rust-musl-builder:latest as builder

WORKDIR /home/rust

# Cargo requires $USER to be set
ENV USER=rust

# Copy all the sources
COPY --chown=rust:rust function ./function
COPY --chown=rust:rust main ./main

RUN cargo install --path ./main

FROM alpine:latest as runner

# Install packages
# RUN sudo apt install -y curl ca-certificates
RUN apk --no-cache add curl ca-certificates \
    && addgroup -S app && adduser -S -g app app

# Copy of-watchdog binary
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog
COPY --from=builder \
    /home/rust/.cargo/bin/main \
    /usr/local/bin/

ENV USER=app

# Set up watchdog for HTTP mode
ENV fprocess="main"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:3000"
ENV write_debug="true"

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
