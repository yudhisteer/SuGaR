FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Copy dependency files
COPY system_dependencies.txt /tmp/
COPY sugar_environment.yml /tmp/

# Install system dependencies from file
RUN apt-get update && \
    cat /tmp/system_dependencies.txt | grep -v "^#" | xargs apt-get install -y --no-install-recommends

# Set GCC-10 as default compiler
ENV CC=/usr/bin/gcc-10
ENV CXX=/usr/bin/g++-10
ENV CUDAHOSTCXX=/usr/bin/g++-10

# Install COLMAP with the working configuration
RUN cd /tmp && \
    git clone --depth 1 https://github.com/colmap/colmap.git && \
    cd colmap && \
    rm -rf build && \
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

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Add conda to path
ENV PATH="/root/miniconda3/bin:${PATH}"

# Create environment from yml file
RUN conda env create -f /tmp/sugar_environment.yml

# Activate sugar environment in bashrc
RUN echo "conda activate sugar" >> ~/.bashrc

# Clone and setup SuGaR
RUN /bin/bash -c "source /root/miniconda3/bin/activate sugar && \
    git clone https://github.com/yudhisteer/SuGaR.git && \
    cd SuGaR && \
    git clone https://github.com/NVlabs/nvdiffrast && \
    cd nvdiffrast && pip install . && cd .. && \
    cd gaussian_splatting/submodules/diff-gaussian-rasterization/ && \
    pip install -e . && \
    cd ../simple-knn/ && pip install -e . && cd ../../../"

WORKDIR /SuGaR
CMD ["/bin/bash"]
