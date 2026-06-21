# Use a modern, official Ubuntu base image
FROM ubuntu:24.04

# Avoid interactive prompts during apt package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# These include both the core build tools and the packages needed by the dotfiles installer
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    git \
    build-essential \
    stow \
    locales \
    unzip \
    zsh \
    neovim \
    zoxide \
    fzf \
    ripgrep \
    fd-find \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    jq \
    poppler-utils \
    imagemagick \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

# Set up UTF-8 locale (essential for terminal icons, starship, and Neovim/Yazi rendering)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root developer user with sudo privileges
# This ensures files are placed in a normal home directory (~/) rather than /root,
# matching a realistic user system environment.
RUN useradd -m -s /bin/zsh developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the developer user
USER developer
WORKDIR /home/developer

# Setup user directories and ensure correct PATH
RUN mkdir -p /home/developer/.local/bin /home/developer/.config
ENV PATH="/home/developer/.local/bin:${PATH}"

# Set terminal environment variable
ENV TERM=xterm-256color

# Copy dotfiles into the container home directory
COPY --chown=developer:developer . /home/developer/dotfiles

# Run the installation script in non-interactive mode
# This tests the installer end-to-end and sets up the configurations/plugins
RUN cd /home/developer/dotfiles && \
    ./install.sh --non-interactive --profile full

# Default shell to Zsh and start interactive shell
ENV SHELL=/bin/zsh
WORKDIR /home/developer
CMD ["/bin/zsh"]
