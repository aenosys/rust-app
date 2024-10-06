# Use the official Rust image as the base for building
FROM rust:1.70 AS builder

# Set the working directory inside the container
WORKDIR /usr/src/rust-app

# Copy the Cargo.toml and Cargo.lock (if it exists)
COPY Cargo.toml Cargo.lock ./

# Create a dummy main.rs to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build only the dependencies (to cache)
RUN cargo build --release

# Remove the dummy src/main.rs and copy the real project files
RUN rm -r src
COPY . .

# Build the full project
RUN cargo build --release

# Final stage: Use a smaller base image
FROM debian:buster-slim

# Set the working directory for the final image
WORKDIR /usr/src/rust-app

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/rust-app/target/release/rust-app .

# Expose port 8080
EXPOSE 8080

# Command to run the Rust app
CMD ["./rust-app"]
