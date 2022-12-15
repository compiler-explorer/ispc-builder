FROM ubuntu:20.04
MAINTAINER Matt Godbolt <matt@godbolt.org>

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update -y -q && apt upgrade -y -q && apt update -y -q && \
    apt install -y -q \
    build-essential \
    bzip2 \
    curl \
    git \
    linux-libc-dev \
    make \
    python3 \
    unzip \
    xz-utils && \
    cd /tmp && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws*

WORKDIR /root

RUN curl -sL https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0-Linux-x86_64.tar.gz | tar xzvf -
RUN ln -s /root/cmake-3.18.0-Linux-x86_64/bin/cmake /bin/cmake

RUN mkdir -p /root
COPY build /root/

WORKDIR /root
