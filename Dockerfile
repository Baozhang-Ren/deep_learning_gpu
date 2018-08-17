###Tools for Deep Learning###
#Base Image
FROM nvidia/cuda:9.0-base-ubuntu16.04

RUN apt-get update && \
    apt-get install -y \
                    wget \
                    xz-utils \
                    build-essential \
                    libsqlite3-dev \
                    libreadline-dev \
                    libssl-dev \
                    openssl
# Python 3.5
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.5.0/Python-3.5.0.tar.xz
RUN tar -xf Python-3.5.0.tar.xz
WORKDIR /tmp/Python-3.5.0
RUN ./configure
RUN make
RUN make install
WORKDIR /
RUN rm -rf /tmp/Python-3.5.0.tar.xz /tmp/Python-3.5.0

# Jupyter Notebook
#
# Allow access from outside the container, and skip trying to open a browser.
# NOTE: disable authentication token for convenience. DON'T DO THIS ON A PUBLIC SERVER.
RUN pip3 --no-cache-dir install jupyter && \
    mkdir /root/.jupyter && \
    echo "c.NotebookApp.ip = '*'" \
         "\nc.NotebookApp.open_browser = False" \
         "\nc.NotebookApp.token = ''" \
         > /root/.jupyter/jupyter_notebook_config.py
EXPOSE 8888

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-9-0 \
        cuda-cublas-9-0 \
        cuda-cufft-9-0 \
        cuda-curand-9-0 \
        cuda-cusolver-9-0 \
        cuda-cusparse-9-0 \
        curl \
        libcudnn7=7.1.4.18-1+cuda9.0 \
        libnccl2=2.2.13-1+cuda9.0 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install TensorFlow CPU version.
RUN pip3 install -U --pre pip setuptools wheel
RUN pip3 install -U --pre numpy scipy matplotlib scikit-learn scikit-image
RUN pip3 install -U --pre tensorflow

#Keras with GPU support
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade setuptools --ignore-installed
RUN pip3 install --upgrade --no-deps  keras

#install tensorflow GPU
RUN pip3 install -U --pre tensorflow-gpu

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# TensorBoard
EXPOSE 6006


# OpenCV 3.4.2
#
# Dependencies
RUN apt-get update && apt-get install --no-install-recommends  -y \
    git cmake build-essential pkg-config libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libgtk-3-dev libatlas-base-dev gfortran python3.5-dev qt-sdk


# Science libraries and other common packages
RUN pip3 --no-cache-dir install \
    numpy scipy sklearn scikit-image pandas matplotlib Cython requests

# PyCocoTools
#
# Using a fork of the original that has a fix for Python 3.
# I submitted a PR to the original repo (https://github.com/cocodataset/cocoapi/pull/50)
# but it doesn't seem to be active anymore.

RUN pip3 install --no-cache-dir git+https://github.com/waleedka/coco.git#subdirectory=PythonAPI


# Get opencv from github
RUN cd /usr/local/src/
RUN git clone https://github.com/opencv/opencv.git 
RUN git clone https://github.com/opencv/opencv_contrib.git 
# Compile
RUN cd opencv && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D INSTALL_C_EXAMPLES=ON \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D WITH_TBB=ON \
      -D WITH_V4L=ON \
      -D WITH_QT=ON \
      -D WITH_OPENGL=ON \
      -D OPENCV_EXTRA_MODULES_PATH= /usr/local/src/opencv_contrib/modules \
      -D BUILD_EXAMPLES=ON .. && \
    make -j"$(nproc)" && \
    make install

#Copy files
RUN cd /home
COPY requirements.txt /home
RUN pip3 install -r requirements.txt
RUN rm requirements.txt
WORKDIR "/root"
CMD ["/bin/bash"]

