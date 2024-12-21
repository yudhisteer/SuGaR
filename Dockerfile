FROM yuvish01/sugar:latest
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
   build-essential cmake ninja-build git libboost-all-dev \
   libeigen3-dev libflann-dev libfreeimage-dev libgoogle-glog-dev \
   libgtest-dev libsqlite3-dev libglew-dev qtbase5-dev \
   libqt5opengl5-dev libcgal-dev libceres-dev libopencv-dev \
   libglfw3-dev freeglut3-dev libmetis-dev libassimp-dev \
   libgtk-3-dev libavdevice-dev libavcodec-dev libxxf86vm-dev \
   libembree-dev gcc-10 g++-10 python3 python3-pip ffmpeg \
   libtiff-dev libtiff5 && \
   apt-get clean && rm -rf /var/lib/apt/lists/*
USER docker_user