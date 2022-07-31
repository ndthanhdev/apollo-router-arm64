FROM debian:bullseye-slim
COPY ./router /router

LABEL org.opencontainers.image.source="https://github.com/ndthanhdev/apollo-router-arm64"
