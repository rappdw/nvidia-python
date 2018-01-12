FROM python:3.6.3 as python
FROM nvidia/cuda:8.0-cudnn6-runtime-ubuntu16.04
ENV PYTHON_VERSION 3.6.3
ENV PYTHON_PIP_VERSION 9.0.1

COPY --from=python /usr/local/bin /usr/local/bin
COPY --from=python /usr/local/lib /usr/local/lib
COPY --from=python /usr/local/include /usr/local/include
COPY --from=python /usr/local/man /usr/local/man
COPY --from=python /usr/local/share /usr/local/share

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
