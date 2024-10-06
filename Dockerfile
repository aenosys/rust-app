# Stage 1: Build the Rust project
FROM rust:1.72 AS builder

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

# Stage 2: Build a smaller runtime image
FROM debian:buster-slim

# Install required dependencies (if any) for running the Rust app
RUN apt-get update && apt-get install -y \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory for the runtime container
WORKDIR /usr/src/rust-app

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/rust-app/target/release/rust-app .

# Expose port 8080
EXPOSE 8080

# Command to run the Rust app
CMD ["./rust-app"]
