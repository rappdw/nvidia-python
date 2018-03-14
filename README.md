# Docker Image for: Python 3.6 + NVIDIA (CUDA & cudNN) drivers

This is a docker image that support python running
on a host that (optionally) has a GPU. GPU support requires nvidia-docker (2.0) 
to be installed on the host system.

This is essentially a mashup of the python docker image and the nvidia-docker image.

The recommended method for consuming this base image is to utilize [docker-utils](https://github.com/rappdw/docker-utils).
In particular, observe the **Tensorflow for both CPU and GPU in the same container** sub-section
in the **Patterns** section of the readme for that project.



