# Docker Image for: Python 3.6 + NVIDIA (CUDA & cudNN) drivers + TensorFlow

This is a docker image that supports python running
on a host that (optionally) has a GPU. GPU support requires nvidia-docker (2.0) 
to be installed on the host system.

The primary use case of this image is to run a docker container
that supports both the CPU and GPU versions of TensorFlow. Both the CPU and GPU versions are installed in their own
virtual environments (/.cpu-env and /.gpu-env respectively), where those environments 
can utilize system site packages.

The documentation for TensorFlow indicates that you must choose either CPU support
or GPU support when installing ([Installing TensorFlow](https://www.tensorflow.org/install/install_linux)).
This approach provides both in one Docker image.

This is essentially a mashup of the python docker image and the nvidia-docker image.

See [dockerutils](https://github.com/rappdw/docker-utils) for more details on docker
patterns for both CPU and GPU.


