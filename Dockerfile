FROM spack/rockylinux9:1.1.1

# Create a custom Spack repository
RUN . /opt/spack/share/spack/setup-env.sh && \
    spack repo create /opt/custom-repo custom

# Configure Spack to use system git as external package
RUN . /opt/spack/share/spack/setup-env.sh && \
    spack external find git && \
    spack config add "packages:git:buildable:false"

# Copy both package.py files into the custom repo
RUN mkdir -p /opt/custom-repo/spack_repo/custom/packages/fre_commands
RUN mkdir -p /opt/custom-repo/spack_repo/custom/packages/bronx_23
COPY fre-commands/package.py /opt/custom-repo/spack_repo/custom/packages/fre_commands/package.py
COPY bronx-23/package.py /opt/custom-repo/spack_repo/custom/packages/bronx_23/package.py

# Add the custom repo to Spack and install both packages
RUN . /opt/spack/share/spack/setup-env.sh && \
    spack repo add /opt/custom-repo/spack_repo/custom && \
    spack install fre-commands@bronx-23 && \
    spack install bronx-23

# Install Lmod and set up module system
RUN dnf install -y lua lua-posix tcl Lmod && \
    dnf clean all

# Set up environment for testing
RUN . /opt/spack/share/spack/setup-env.sh && \
    echo ". /opt/spack/share/spack/setup-env.sh" >> /root/.bashrc && \
    echo "export MODULEPATH=/opt/spack/share/spack/lmod/linux-rocky9-x86_64/Core:\${MODULEPATH}" >> /root/.bashrc

# Find and display the modulefile location for verification
RUN . /opt/spack/share/spack/setup-env.sh && \
    echo "=== Modulefile location ===" && \
    find /opt/spack -name "bronx-23.lua" -type f 2>/dev/null || echo "Modulefile not found in expected location"

