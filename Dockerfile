# syntax=docker/dockerfile:1
# Needs BuildKit (default in Docker Desktop) for the `RUN --mount=type=cache`
# and `ADD --checksum` below; the syntax directive pins a frontend that supports
# them.

# Requires the decoupled base (user via $DEV_USER, project mount at /workspace):
# rebuild+push dsaenztagarro/dev-env at this tag before building this image.
FROM dsaenztagarro/dev-env:2.0.1

# Re-declare so $DEV_USER expands in this build stage too (default matches the
# base's ENV). The base must actually create this user — this only names it.
ARG DEV_USER=me

USER root

# Keep downloaded .debs so the apt cache mount below is populated across rebuilds
# (Ubuntu's default /etc/apt/apt.conf.d/docker-clean discards them post-install).
RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# clangd: C/C++ LSP. gdb: alire's own GDB lacks the DAP interpreter. python3/pip:
# the testsuite. unzip: extract the pinned alr release fetched below.
# Cache mounts persist apt's package + list caches across builds (they even
# survive the base image's --no-cache), so re-installs don't re-download.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
      clangd gdb python3 python3-pip unzip

USER $DEV_USER

### Alire

# Fetch a PINNED, stable alr release. Native aarch64-linux binaries ship in
# Alire's versioned releases since PR #1832, so we no longer vendor a nightly.
# `ADD --checksum` verifies the sha256 and is layer-cached by URL+checksum, so it
# re-downloads only when the version (and thus the hash) changes — not per build.
# Bump ALR_VERSION and the checksum together from the releases page:
#   https://github.com/alire-project/alire/releases
ARG ALR_VERSION=2.1.1
ADD --chown=$DEV_USER:$DEV_USER \
    --checksum=sha256:d76c93ad3dc631826144e10bdabc6b3bf98783805bebfd5e4a0e852dd524d812 \
    https://github.com/alire-project/alire/releases/download/v${ALR_VERSION}/alr-${ALR_VERSION}-bin-aarch64-linux.zip \
    /tmp/alr.zip
RUN unzip -q /tmp/alr.zip -d /home/$DEV_USER/lib/alr-${ALR_VERSION} && rm /tmp/alr.zip

# The Ada Language Server has no upstream aarch64 release to pin yet, so it stays
# vendored under third_party/.
COPY ./third_party/ada_language_server /home/$DEV_USER/lib/ada_language_server

# Symlink into /home/$DEV_USER/bin, which the base image keeps on PATH.
RUN ln -sf /home/$DEV_USER/lib/alr-${ALR_VERSION}/bin/alr /home/$DEV_USER/bin/alr
RUN ln -sf /home/$DEV_USER/lib/ada_language_server /home/$DEV_USER/bin/ada_language_server

# Install default version for gprbuild and gnat_native
RUN alr --non-interactive toolchain --select

WORKDIR /workspace

# Development Goodies
RUN echo 'alias gcc="alr exec -- gcc"' >> ${BASHRC_PATH}
RUN echo 'alias gdb="gdb --quiet"' >> ${BASHRC_PATH}
# RUN echo 'alias gdb="alr exec -- gdb --quiet"' >> ${BASHRC_PATH}
# ^
# --quiet : skip GDB licensing information
RUN echo 'alias gnatmake="alr exec -- gnatmake"' >> ${BASHRC_PATH}
RUN echo 'alias gnatbind="alr exec -- gnatbind"' >> ${BASHRC_PATH}
RUN echo 'alias gprbuild="alr exec -- gprbuild"' >> ${BASHRC_PATH}

# RUN alr install ada_language_server

USER root

# RUN sudo rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER $DEV_USER

# Set default shell to Bash
ENTRYPOINT ["/bin/bash"]
