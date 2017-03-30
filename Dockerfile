# Start with CUDA Torch dependencies 2
FROM kaixhin/cuda-torch-deps:2-8.0
MAINTAINER Kai Arulkumaran <design@kaixhin.com>

# Install git, apt-add-repository and dependencies for iTorch
RUN apt-get update && apt-get install -y \
  git \
  software-properties-common \
  ipython3 \
  libssl-dev \
  libzmq3-dev \
  python-zmq \
  python-pip \
  wget \
  sudo

# Install Jupyter Notebook for iTorch
#RUN pip install --upgrade pip
#RUN pip install notebook
#RUN pip install ipywidgets

# Run Torch7 installation scripts (dependencies only)
RUN git clone https://github.com/torch/distro.git /root/torch --recursive && cd /root/torch && \
  bash install-deps

#FROM kaixhin/cuda-torch-deps:7.5
MAINTAINER Kai Arulkumaran <design@kaixhin.com>

# Run Torch7 installation scripts
RUN cd /root/torch && \
# Run without nvcc to prevent timeouts
  sed -i 's/path_to_nvcc=$(which nvcc)/path_to_nvcc=$(which no_nvcc)/g' install.sh && \
  sed -i 's,path_to_nvcc=/usr/local/cuda/bin/nvcc,path_to_nvcc=,g' install.sh && \
  ./install.sh

# Export environment variables manually
ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
ENV LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
ENV PATH=/root/torch/install/bin:$PATH
ENV LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH
ENV DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH
ENV LUA_CPATH='/root/torch/install/lib/?.so;'$LUA_CPATH

# Set ~/torch as working directory
WORKDIR /root/torch

# Start with CUDA Torch dependencies 2
#FROM kaixhin/cuda-torch-deps:2-7.5
MAINTAINER Kai Arulkumaran <design@kaixhin.com>

# Restore Torch7 installation script
RUN sed -i 's/path_to_nvcc=$(which no_nvcc)/path_to_nvcc=$(which nvcc)/g' install.sh

RUN sudo apt-get install -y libprotobuf-dev protobuf-compiler

# Install CUDA libraries
RUN luarocks install torch
RUN luarocks install cutorch
RUN luarocks install cunn
RUN luarocks install cudnn
RUN luarocks install matio
RUN luarocks install loadcaffe

WORKDIR /root

RUN git clone -b dockerize https://github.com/davidpkatz/deep-photo-styletransfer.git && \
  cd deep-photo-styletransfer/models
RUN apt-get install -y wget
WORKDIR /root/deep-photo-styletransfer/models
RUN wget -c https://gist.githubusercontent.com/ksimonyan/3785162f95cd2d5fee77/raw/bb2b4fe0a9bb0669211cf3d0bc949dfdda173e9e/VGG_ILSVRC_19_layers_deploy.prototxt && \
  wget -c http://www.robots.ox.ac.uk/~vgg/software/very_deep/caffe/VGG_ILSVRC_19_layers.caffemodel && \
  wget -c http://sceneparsing.csail.mit.edu/model/DilatedNet_iter_120000.caffemodel

WORKDIR /root/deep-photo-styletransfer
RUN make clean && make