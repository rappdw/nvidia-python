FROM python:3.6.4 as python

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
#        b) Install any python modules with scripts into system site packages, but run 'fix-shebang'
#           to reset the python specification to use `/usr/bin/env` rather than hard-coding to the
#           python in system (works well for large modules or modules that have lengthy installs)
#
#           This is the option selected for this docker image. fix-shebang is placed into /etc/profile.d,
#           .bashrc, and .bash_profile are setup to ensure that the correct CPU/GPU env, and fix-shebang
#           are invoked for any common bash shell instantiations (login, interactive non-login, and
#           non-interactive shells).
#
# 3) In each of the virtual environments, install the appropriate TensorFlow (as well as any modules
#    with scripts and work-around b).
#
###
COPY setup-venv /tmp/
COPY requirements.txt /tmp/
COPY fix-shebang /usr/local/bin/

RUN pip install -U pip
RUN pip install -r /tmp/requirements.txt
RUN /tmp/setup-venv
RUN . /cpu-env \
    && pip install -U pip \
    && pip install tensorflow==1.4.0
RUN . /gpu-env \
    && pip install -U pip \
    && pip install tensorflow-gpu==1.4.0

FROM nvidia/cuda:8.0-cudnn6-runtime-ubuntu16.04
LABEL maintainer="rappdw@gmail.com"
ENV PYTHON_VERSION=3.6.3 \
    PYTHON_PIP_VERSION=9.0.3

COPY --from=python /usr/local /usr/local
COPY --from=python /.cpu-env /.cpu-env
COPY --from=python /.gpu-env /.gpu-env

# setup useful links and install some dependencies for python
RUN ln -s /.cpu-env/bin/activate /cpu-env \
    && ln -s /.gpu-env/bin/activate /gpu-env \
    && ldconfig \
    && cd /usr/local/bin \
    && rm idle pydoc python python-config \
	&& ln -Fs idle3 idle \
	&& ln -Fs pydoc3 pydoc \
	&& ln -Fs python3 python \
	&& ln -Fs python3-config python-config \
    && apt-get update && apt-get install -y --no-install-recommends \
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
#COPY root_dir/* /root/
#COPY cpu-gpu-env.sh /etc/profile.d/cpu-gpu-env.sh
#ENV BASH_ENV=/etc/profile.d/cpu-gpu-env.sh
COPY ./docker-entrypoint.sh /
CMD []
ENTRYPOINT ["/docker-entrypoint.sh"]