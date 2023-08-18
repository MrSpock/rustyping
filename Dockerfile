## RUN cargo update when transmute error occurs. This is due to rust 1.64 changes..
FROM rust:1.71-alpine3.18 as build

# create a new empty shell project
RUN USER=root cargo new --bin rustyping
WORKDIR /rustyping

# copy Cargo files
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# this build cache dependencies
RUN apk add musl-dev
RUN cargo build --release
RUN rm src/*.rs

# copy  source tree
COPY ./src ./src

# build for release
RUN rm ./target/release/deps/rustyping*
RUN cargo build --release

# our final base
FROM rust:1.71-alpine3.18

# copy the build artifact from the build stage
COPY --from=build /rustyping/target/release/rustyping .

# set the startup command to run your binary
CMD ["./rustyping", "--redis_host", "redis"]
