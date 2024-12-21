FROM yuvish01/sugar:latest
USER root
# Add NVIDIA runtime dependencies
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics

# Add OpenGL/EGL dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libegl1-mesa-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    libxxf86vm-dev \
    && rm -rf /var/lib/apt/lists/*

# Keep your existing CMD
CMD ["/bin/bash"]