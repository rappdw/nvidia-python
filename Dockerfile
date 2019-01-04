#
# based on https://github.com/docker-library/python/blob/ab8b829cfefdb460ebc17e570332f0479039e918/3.7/stretch/Dockerfile
#
FROM ubuntu:16.04 as python

ENV PATH /usr/local/bin:$PATH
ENV LANG C.UTF-8

RUN apt-get update; \
    apt-get install -y \
        build-essential \
        openssl \
        libssl-dev \
        tk-dev \
        uuid-dev \
        wget \
    ; \
    apt-get clean; \
    rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION 3.6.8

RUN set -ex \
	\
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& ldconfig \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' + \
	&& rm -rf /usr/src/python \
	\
	&& python3 --version

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 18.1

RUN set -ex; \
	\
	wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
	\
	python3 get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

#
# based on https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/docker/Dockerfile.gpu
#
FROM nvidia/cuda:9.0-base-ubuntu16.04
ARG DEBIAN_FRONTEND=noninteractive
LABEL maintainer="rappdw@gmail.com"

ENV PYTHON_VERSION=3.6.8 \
    PYTHON_PIP_VERSION=18.1

COPY --from=python /usr/local /usr/local

# setup useful links python
RUN ldconfig \
    && cd /usr/local/bin \
	&& ln -Fs idle3 idle \
	&& ln -Fs pydoc3 pydoc \
	&& ln -Fs python3 python \
	&& ln -Fs python3-config python-config

# pick up some TF and python dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-9-0 \
        cuda-cublas-9-0 \
        cuda-cufft-9-0 \
        cuda-curand-9-0 \
        cuda-cusolver-9-0 \
        cuda-cusparse-9-0 \
        libcudnn7=7.2.1.38-1+cuda9.0 \
        libnccl2=2.2.13-1+cuda9.0 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng12-dev \
        libzmq3-dev \
        unzip \
        tcl \
		tk \
		libffi-dev \
		libgomp1 \
	&& apt-get clean \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install nvinfer-runtime-trt-repo-ubuntu1604-4.0.1-ga-cuda9.0 \
    && apt-get update \
    && apt-get install libnvinfer4=4.1.2-1+cuda9.0 \
	&& apt-get clean \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64

RUN set -ex; \
    pip install --no-cache-dir \
        tensorflow-gpu \
    ; \
    rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

# setup entrypoint
ADD docker-entrypoint.sh /usr/local/bin
CMD ["/bin/bash"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
