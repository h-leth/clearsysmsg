FROM rust:1.89 AS build

# set unprivileged user
USER nobody

# create a empty shell project
RUN cargo new /tmp/clearsysmsg

# copy manifests
WORKDIR /tmp/clearsysmsg
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# cache dependencies
RUN cargo build --release
RUN rm src/*.rs

# copy source tree
COPY ./src ./src

# build for release
RUN rm ./target/release/deps/clearsysmsg*
RUN cargo build --release

# final base image
FROM debian:bookworm-slim

# install system dependencies
RUN apt-get update
RUN apt-get install -y libssl-dev ca-certificates
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

# copy binary 
COPY --from=build /tmp/clearsysmsg/target/release/clearsysmsg /usr/bin/

# startup command
CMD ["usr/bin/clearsysmsg"]
