FROM python:3.7.2 as python
RUN pip install -U pip

FROM nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04
ARG DEBIAN_FRONTEND=noninteractive
LABEL maintainer="rappdw@gmail.com"

ENV PYTHON_VERSION=3.7.2 \
    PYTHON_PIP_VERSION=18.1

COPY --from=python /usr/local /usr/local

# setup useful links and install some dependencies for python
RUN ldconfig \
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
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

# setup entrypoint
ADD docker-entrypoint.sh /usr/local/bin
CMD ["/bin/bash"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
