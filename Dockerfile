# Stage 1: Build the Rust project
FROM rust:1.72-slim AS builder

# Set the working directory inside the container
WORKDIR /usr/src/rust-app

# Copy the Cargo.toml and Cargo.lock files to build dependencies
COPY Cargo.toml Cargo.lock ./

# Create an empty src directory to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build only the dependencies, to cache them
RUN cargo build --release

# Remove the dummy src/main.rs and copy the actual source code
RUN rm -r src
COPY . .

# Build the actual project
RUN cargo build --release

# Stage 2: Create a smaller runtime image
FROM debian:buster-slim

# Set the working directory
WORKDIR /usr/src/rust-app

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/rust-app/target/release/rust-app .

# Expose port 8080
EXPOSE 8080

# Command to run the Rust app
CMD ["./rust-app"]
