FROM rust:latest AS builder

ARG router_version=0.11.0

RUN apt update && apt-get install -y gcc-aarch64-linux-gnu npm g++-aarch64-linux-gnu libc6-dev-arm64-cross

ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc \
    CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc \
    CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++

# Build router
WORKDIR /router
RUN git clone https://github.com/apollographql/router --depth=1 --branch v$router_version /router

# install the toolchain specified by the project
RUN rustup show
RUN rustup target add aarch64-unknown-linux-gnu
RUN rustup default 1.60.0
RUN rustup target add aarch64-unknown-linux-gnu

RUN cargo build --release --target aarch64-unknown-linux-gnu


FROM debian:bullseye-slim AS final
WORKDIR /router

RUN apt-get update && apt-get -y install openssl ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /router/target/aarch64-unknown-linux-gnu/release/router .

# Default executable is the router
ENTRYPOINT ["./router"]

LABEL org.opencontainers.image.source="https://github.com/ndthanhdev/apollo-router-arm64"
