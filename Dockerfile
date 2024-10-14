# Use a base image that supports GUI applications
FROM debian:latest

# Set environment variables for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# Install necessary dependencies for building GIMP, noVNC, and websockify
RUN apt-get update && \
    apt-get install -y \
    wget \
    git \
    build-essential \
    cmake \
    libglib2.0-dev \
    libgtk-3-dev \
    libgimp2.0-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    libopenexr-dev \
    libgexiv2-dev \
    libpango1.0-dev \
    libgtkglext1-dev \
    libgif-dev \
    python3 \
    python3-pip \
    python3-setuptools \
    x11vnc \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Download and install GIMP 2.10.34
RUN wget https://download.gimp.org/mirror/pub/gimp/v2.10/gimp-2.10.34.tar.bz2 && \
    tar -xjf gimp-2.10.34.tar.bz2 && \
    cd gimp-2.10.34 && \
    ./autogen.sh && \
    make && \
    make install && \
    ldconfig && \
    cd .. && \
    rm -rf gimp-2.10.34 gimp-2.10.34.tar.bz2

# Clone noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /noVNC && \
    cd /noVNC && \
    git submodule update --init --recursive && \
    pip3 install numpy

# Expose the noVNC port
EXPOSE 6080

# Create a startup script to initialize the environment and start services
RUN echo '#!/bin/bash\n\
Xvfb :99 -screen 0 1280x720x24 &\n\
DISPLAY=:99 gimp &\n\
python3 /noVNC/utils/websockify/run --web /noVNC --cert /etc/ssl/certs/ssl-cert-snakeoil.pem --key /etc/ssl/private/ssl-cert-snakeoil.key 6080 localhost:5900\n' > /start.sh && \
    chmod +x /start.sh

# Set the command to run the startup script
CMD ["/start.sh"]
