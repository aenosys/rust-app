# Use the official Rust image as the base for building
FROM rust:1.70 AS builder

# Set the working directory inside the container
WORKDIR /usr/src/rust-app

# Copy the Cargo.toml and Cargo.lock (if it exists) to the container
COPY Cargo.toml Cargo.lock ./

# Create an empty src/main.rs to build dependencies without the actual code
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build dependencies (this step is cached to optimize build times)
RUN cargo build --release

# Remove the dummy src/main.rs, and copy the real project files
RUN rm -r src
COPY . .

# Build the full project
RUN cargo build --release

# Optionally, remove the release artifacts related to dependencies to reduce image size
# Remove this line temporarily if you are troubleshooting:
# RUN rm -f target/release/deps/rust_app*

# Use a smaller base image for the final stage
FROM debian:buster-slim

# Install required dependencies (in case your Rust binary needs some system dependencies)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the final image
WORKDIR /usr/src/rust-app

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/rust-app/target/release/rust-app .

# Expose the port the app runs on (adjust as needed)
EXPOSE 8080

# Command to run the Rust app
CMD ["./rust-app"]
