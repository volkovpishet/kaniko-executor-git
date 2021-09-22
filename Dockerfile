FROM gcr.io/kaniko-project/executor:debug

ARG user=kaniko
ARG group=kaniko
ARG uid=1000
ARG gid=1000

ENV NIX_VERSION="nix-2.3.15"
ENV NIX_VERSION_WITH_PLATFORM="${NIX_VERSION}-x86_64-linux"

SHELL ["/busybox/sh", "-c"]

# Nix installer does not support install from root, user creation is required
RUN touch /etc/passwd
RUN touch /etc/group
RUN echo root:x:0:0:root:/root:/bin/sh > /etc/passwd
RUN mkdir -p -m 0755 /home/${user}
RUN addgroup -g ${gid} -S ${group}
RUN adduser -D -u ${uid} -G ${group} -S ${user}
RUN chown -R ${user} /home/${user}

# Create directories needed by nix package manager installer and set correct rights
RUN mkdir -m 0755 /nix
RUN chown -R ${user} /nix
RUN mkdir -m 0777 /tmp

# Install nix package manager
USER ${uid}:${gid}
ENV HOME /home/${user}
WORKDIR $HOME
RUN wget https://releases.nixos.org/nix/${NIX_VERSION}/${NIX_VERSION_WITH_PLATFORM}.tar.xz
RUN tar xf nix-*
WORKDIR $HOME/${NIX_VERSION_WITH_PLATFORM}
RUN /busybox/sh install

# Install git and link it to directory specified in PATH
RUN . ~/.nix-profile/etc/profile.d/nix.sh && nix-env -iA nixpkgs.git
USER root
RUN ln -s /home/${user}/.nix-profile/bin/git /busybox/git

# Change default entrypoint to shell
ENTRYPOINT ["/busybox/sh", "-c"]
