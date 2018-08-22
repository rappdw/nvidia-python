FROM nvidia/cuda:9.2-devel-ubuntu18.04
ARG DEBIAN_FRONTEND=noninteractive
LABEL maintainer="rappdw@gmail.com"

RUN apt-get update; \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
    ; \
    apt-get clean; \
    rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

# Setup venv to use generally so we don't "vandalize" the linux system
RUN python3 -m venv --prompt='py36' /.venv; \
    . /.venv/bin/activate; \
    pip install --no-cache-dir -U pip

# setup entrypoint that activates the virtual environment
ADD docker-entrypoint.sh /usr/local/bin
CMD ["/bin/bash"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
