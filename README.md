# deep_learning_gpu

This is a docker image build from nvidia/cuda and originally built for live image classification and segmentaion using Mask-RCNN.

# Base Image
  nvidia/cuda:9.0-base-ubuntu16.04

# Libraries Included
Ubuntu 16.04 \
Python 3.5.0 \
Jupyter Notebook \
Tensorflow-gpu 1.10.0 \
Keras \
OpenCV 3.4.2 with opencv_contrib \
PyCocoTools \
numpy \
scipy \
Pillow \
cython \
matplotlib \
scikit-image \
h5py \
imgaug \
pyyaml

# Runing The image 
To pull the image from Docker Hub
```
docker pull arabellaren/deep_learning_gpu
```
To run the image, use nvidia-docker instead of docker
```
nvidia-docker -p 8888:8888 -it arabellaren/deep_learning_gpu sh
```
