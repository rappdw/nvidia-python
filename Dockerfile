#
# based on https://github.com/docker-library/python/blob/ab8b829cfefdb460ebc17e570332f0479039e918/3.7/stretch/Dockerfile
#
FROM ubuntu:18.04 as python
ARG DEBIAN_FRONTEND=noninteractive

ENV PATH /usr/local/bin:$PATH
ENV LANG C.UTF-8

RUN apt-get update; \
    apt-get install -y \
        build-essential \
        openssl \
        libffi-dev \
        libssl-dev \
        tk-dev \
        uuid-dev \
        wget \
    ; \
    apt-get clean; \
    rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION 3.7.2

RUN set -ex \
	\
	&& wget -qO python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -qO python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
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
	wget -qO get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
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
# based on https://gitlab.com/nvidia/cuda/blob/ubuntu18.04/10.0/runtime/Dockerfile
# and
#
FROM nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04
ARG DEBIAN_FRONTEND=noninteractive
LABEL maintainer="rappdw@gmail.com"

ENV PYTHON_VERSION=3.7.2 \
    PYTHON_PIP_VERSION=18.1

COPY --from=python /usr/local /usr/local

# setup useful links for python
RUN ldconfig \
    && cd /usr/local/bin \
	&& ln -Fs idle3 idle \
	&& ln -Fs pydoc3 pydoc \
	&& ln -Fs python3 python \
	&& ln -Fs python3-config python-config

# pick up some python and CUDA toolkit dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
		tcl \
		tk \
		libffi-dev \
		libgomp1 \
		libssl-dev \
	&& apt-get clean \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

# setup entrypoint
ADD docker-entrypoint.sh /usr/local/bin
CMD ["/bin/bash"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
