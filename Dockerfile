FROM python:3.6.4 as python

ADD setup-venv.py /tmp/setup-venv
ADD replicate-to-venv /usr/local/bin/replicate-to-venv
ADD requirements.txt /tmp/requirements.txt
###
# In creating an image that supports either CPU or GPU versions of TensorFlow we do
# the following:
#
# 1) Install into the system site packages all modules that TensorFlow is dependant upon
# 2) Create virtual envionrments for both the CPU and GPU (with --system-site-packages)
#      This is done for a couple of reasons:
#        a) to optimize the size of the docker image
#        b) to optimize the time it takes to build the docker image
#      This does present some problmes. Namely, any python scripts (jupyter, pytest, etc.)
#      that are installed into the system site packages will resolve sys.prefix according to
#      their installation location, meaning that even if you have activated the virtual
#      environment, if your entry into python is via a script, then modules in the virtual
#      environment will not be available.
#
#      There are a few work-arounds for this issue:
#        a) Install any python modules with scripts into both virtual environments rather than
#           into system site packages (works well for modules that aren't large and install quickly)
#        b) Install any python modules with scripts into system site packages, but copy and rewrite
#           script she-bangs for each virtual environment (works well for large modules or modules that
#           have lengthy installs)
#        c) symlink everything in the system site /bin directory (we think)
# 3) In each of the virtual environments, install the appropriate TensorFlow (as well as any modules
#    with scripts and work-around b).
#
###
RUN pip install -U pip
RUN pip install -r /tmp/requirements.txt
RUN /tmp/setup-venv
RUN . /cpu-env \
    && pip install -U pip \
    && pip install tensorflow
RUN . /gpu-env \
    && pip install -U pip \
    && pip install tensorflow-gpu

FROM nvidia/cuda:9.0-cudnn7-runtime-ubuntu16.04
ENV PYTHON_VERSION 3.6.4
ENV PYTHON_PIP_VERSION 9.0.3

COPY --from=python /usr/local/bin /usr/local/bin
COPY --from=python /usr/local/lib /usr/local/lib
COPY --from=python /usr/local/include /usr/local/include
COPY --from=python /usr/local/man /usr/local/man
COPY --from=python /usr/local/share /usr/local/share
COPY --from=python /.cpu-env /.cpu-env
COPY --from=python /.gpu-env /.gpu-env

RUN ln -s /.cpu-env/bin/activate /cpu-env \
    && ln -s /.gpu-env/bin/activate /gpu-env

# make some useful symlinks that are expected to exist
RUN ldconfig \
    && cd /usr/local/bin \
    && rm idle pydoc python python-config \
	&& ln -Fs idle3 idle \
	&& ln -Fs pydoc3 pydoc \
	&& ln -Fs python3 python \
	&& ln -Fs python3-config python-config

# runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		tcl \
		tk \
		libffi-dev \
		libgomp1 \
		libssl-dev \
	&& apt-get clean \
    && rm -rf /var/tmp /tmp /var/lib/apt/lists/* \
    && mkdir -p /var/tmp /tmp

# add .bashrc that detects environment (CPU vs. GPU) and sources the correct
# venv to support the requested env
ADD .bashrc /root/.bashrc
ADD .bash_profile /root/.bash_profile
ENTRYPOINT ["/bin/bash"]