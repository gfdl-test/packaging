# Spack-based Dockerfile
# This Dockerfile sets up a container with Spack package manager for building scientific software

FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies required by Spack
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    environment-modules \
    gfortran \
    git \
    gpg \
    lsb-release \
    python3 \
    python3-distutils \
    python3-venv \
    unzip \
    vim \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone Spack
ENV SPACK_ROOT=/opt/spack
RUN git clone --depth=100 --branch=releases/v0.21 https://github.com/spack/spack.git ${SPACK_ROOT}

# Set up Spack environment
ENV PATH=${SPACK_ROOT}/bin:$PATH
RUN echo "source ${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/spack.sh

# Initialize Spack
RUN . ${SPACK_ROOT}/share/spack/setup-env.sh && \
    spack compiler find && \
    spack external find

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash", "-l"]
