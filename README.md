# packaging

This repository contains a Spack-based Docker container for building scientific software packages.

## Spack Dockerfile

The included Dockerfile provides a containerized environment with [Spack](https://spack.io/), a flexible package manager designed for HPC and scientific computing.

### Features

- Based on Ubuntu 22.04 LTS
- Spack v0.21 pre-installed
- GCC 11.4.0 compiler available
- Common build tools and dependencies included
- Ready for building and installing scientific software packages

### Building the Image

```bash
docker build -t spack-container .
```

### Running the Container

```bash
docker run -it spack-container
```

### Using Spack

Once inside the container, Spack is available via the `spack` command:

```bash
# List available compilers
spack compiler list

# Search for packages
spack list <package-name>

# Install a package
spack install <package-name>

# List installed packages
spack find
```

For more information about Spack, visit the [official documentation](https://spack.readthedocs.io/).