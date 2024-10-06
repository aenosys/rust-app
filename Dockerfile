# Use the official Rust image as the base image
FROM rust:1.70 AS builder

# Set the working directory inside the container
WORKDIR /usr/src/rust-app

# Copy the Cargo.toml and Cargo.lock (if available)
COPY Cargo.toml Cargo.lock ./

# Create a dummy main.rs to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build only the dependencies
RUN cargo build --release && rm -f target/release/deps/rust_app*

# Copy the entire project
COPY . .

# Build the full project
RUN cargo build --release

# Final stage
FROM debian:buster-slim

# Set the working directory
WORKDIR /usr/src/rust-app

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/rust-app/target/release/rust-app .

# Expose port 8080 to the outside world
EXPOSE 8080

# Run the Rust app
CMD ["./rust-app"]
