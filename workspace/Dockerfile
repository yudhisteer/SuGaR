# Stage 1: COLMAP builder
FROM ubuntu:22.04 AS colmap-builder
ENV DEBIAN_FRONTEND=noninteractive
# COPY system_dependencies.txt /tmp/
# RUN apt-get update && \
#     cat /tmp/system_dependencies.txt | grep -v "^#" | xargs apt-get install -y --no-install-recommends

# Base packages first
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates && rm -rf /var/lib/apt/lists/*

# CUDA installation
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates gnupg && \
    wget --no-check-certificate https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get update && apt-get install -y --no-install-recommends cuda-11-8 && \
    rm -rf /var/lib/apt/lists/* *.deb

# Set CUDA environment
ENV PATH="/usr/local/cuda-11.8/bin:${PATH}"
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64
ENV CUDA_HOME=/usr/local/cuda-11.8

# Install base packages first
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    python3 \
    python3-pip \
    ffmpeg \
    ca-certificates \
    cmake \
    ninja-build \
    build-essential \
    libboost-all-dev \
    libeigen3-dev \
    libflann-dev \
    libfreeimage-dev \
    libgoogle-glog-dev \
    libgtest-dev \
    libgmock-dev \
    libsqlite3-dev \
    libglew-dev \
    qtbase5-dev \
    libqt5opengl5-dev \
    libcgal-dev \
    libceres-dev \
    freeglut3-dev \
    libmetis-dev \
    gcc-10 \
    g++-10 \
    libtiff-dev \
    libtiff5 \
    && rm -rf /var/lib/apt/lists/*


# Set GCC-10
ENV CC=/usr/bin/gcc-10 \
    CXX=/usr/bin/g++-10 \
    CUDAHOSTCXX=/usr/bin/g++-10

# Build COLMAP
RUN cd /tmp && \
    git clone --depth 1 https://github.com/colmap/colmap.git && \
    cd colmap && \
    mkdir build && \
    cd build && \
    cmake .. -GNinja \
    -DCMAKE_CUDA_ARCHITECTURES="75;80;86" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-I/usr/include/x86_64-linux-gnu" \
    -DCMAKE_EXE_LINKER_FLAGS="-ltiff -Wl,-rpath,/usr/lib/x86_64-linux-gnu" \
    -DCMAKE_SKIP_RPATH=OFF \
    -DCMAKE_INSTALL_RPATH="/usr/lib/x86_64-linux-gnu" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON && \
    ninja && \
    ninja install


# Stage 2: Final image
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install wget for miniconda
RUN apt-get update && apt-get install -y wget git build-essential ninja-build && rm -rf /var/lib/apt/lists/*

# Copy COLMAP from builder
COPY --from=colmap-builder /usr/local/bin/colmap /usr/local/bin/
COPY --from=colmap-builder /usr/local/lib/ /usr/local/lib/
COPY --from=colmap-builder /usr/local/cuda-11.8 /usr/local/cuda-11.8

ENV PATH="/usr/local/cuda-11.8/bin:${PATH}"
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64
ENV CUDA_HOME=/usr/local/cuda-11.8

# Install Miniconda and setup environment
COPY sugar_environment.yml /tmp/

# Install Miniconda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /root/miniconda3 && \
    rm /tmp/miniconda.sh

ENV PATH="/root/miniconda3/bin:${PATH}"
RUN conda env create -f /tmp/sugar_environment.yml && \
    echo "conda activate sugar" >> ~/.bashrc

# Before the SuGaR installation, add:
ENV TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6"
ENV FORCE_CUDA=1

RUN apt-get update && apt-get install -y gcc-10 g++-10 && rm -rf /var/lib/apt/lists/*

ENV CC=/usr/bin/gcc-10 \
    CXX=/usr/bin/g++-10 \
    CUDAHOSTCXX=/usr/bin/g++-10


# Setup SuGaR
RUN /bin/bash -c "source /root/miniconda3/bin/activate sugar && \
    git clone --depth 1 https://github.com/yudhisteer/SuGaR.git && \
    cd SuGaR && \
    git clone --depth 1 https://github.com/NVlabs/nvdiffrast && \
    cd nvdiffrast && pip install . && cd .. && \
    cd gaussian_splatting/submodules/diff-gaussian-rasterization/ && \
    pip install -e . && \
    cd ../simple-knn/ && pip install -e . && \
    rm -rf /SuGaR/.git /SuGaR/*/submodules/*/.git"

WORKDIR /SuGaR

# Create non-root user
RUN useradd -m docker_user && \
    chown -R docker_user:docker_user /SuGaR /root
USER docker_user

LABEL maintainer="yudhisteer.chin@gmail.com" \
      version="1.0" \
      description="SuGaR with COLMAP and CUDA support"

CMD ["/bin/bash"]