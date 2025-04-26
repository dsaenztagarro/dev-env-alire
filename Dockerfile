FROM dsaenztagarro/dev-env:1.0.1

USER root

RUN apt-get install -y clangd # LSP engine for C, C++
RUN apt-get install -y gdb # alire GDB was not built with support for the DAP
                           # (Debug Adapter Protocol) interpreter
RUN apt-get install -y python3 python3-pip # Testsuite

USER dev

### Alire

# Copy the Alire binary into the image
# https://github.com/alire-project/alire/releases
# alr-nightly-bin-aarch64-linux.zip
COPY ./third_party/alr-nightly-bin-aarch64-linux /home/dev/lib/alr-nightly
COPY ./third_party/ada_language_server/ /home/dev/lib/ada_language_server

# Create the symlink in a user-writable directory
RUN ln -sf /home/dev/lib/alr-nightly/bin/alr /home/dev/bin/alr
RUN ln -sf /home/dev/lib/ada_language_server /home/dev/bin/ada_language_server

# Install default version for gprbuild and gnat_native
RUN alr --non-interactive toolchain --select

WORKDIR /home/dev/workdir

# Development Goodies
RUN echo 'alias gcc="alr exec -- gcc"' >> ${BASHRC_PATH}
RUN echo 'alias gdb="gdb --quiet"' >> ${BASHRC_PATH}
# RUN echo 'alias gdb="alr exec -- gdb --quiet"' >> ${BASHRC_PATH}
# ^
# --quiet : skip GDB licensing information
RUN echo 'alias gnatmake="alr exec -- gnatmake"' >> ${BASHRC_PATH}
RUN echo 'alias gnatbind="alr exec -- gnatbind"' >> ${BASHRC_PATH}
RUN echo 'alias gprbuild="alr exec -- gprbuild"' >> ${BASHRC_PATH}

# RUN apt-get install -y --no-install-recommends ca-certificates apt-transport-https unzip
# RUN alr install ada_language_server

USER root

# RUN sudo rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER dev

# Set default shell to Bash
ENTRYPOINT ["/bin/bash"]
