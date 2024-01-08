# Copyright (c) 2017, Groupon, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# Neither the name of GROUPON nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FROM alpine:3.16

ENV container docker
ARG v
ENV SILO_BASE_VERSION ${v:-UNDEFINED}

ADD pip/pip.conf /etc/pip.conf

LABEL maintainer="Ryan Persée <98691129+rpersee@users.noreply.github.com>"

# Add testing repo, as we need this for installing gosu
RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories &&\

# Install curl
    apk add --no-cache openssl=1.1.1w-r1\
                       ca-certificates=20230506-r0\
                       libssh2=1.11.0-r0\
                       libcurl=8.5.0-r0\
                       curl=8.5.0-r0\

# Install bash
                       ncurses-terminfo-base=6.3_p20220521-r1\
                       ncurses-terminfo=6.3_p20220521-r1\
                       ncurses-libs=6.3_p20220521-r1\
                       readline=8.1.2-r0\
                       bash=5.1.16-r2\

# Install git
                       perl=5.34.2-r0\
                       expat=2.5.0-r0\
                       pcre=8.45-r2\
                       git=2.36.6-r0\

# Install python
                       libbz2=1.0.8-r1\
                       libffi=3.4.2-r1\
                       gdbm=1.23-r0\
                       sqlite-libs=3.40.1-r0\
                       py3-netifaces=0.11.0-r1\

# Install pip
                       py3-pip=22.1.1-r0\

# Install Ansible dependencies
                       yaml=0.2.5-r0\
                       gmp=6.2.1-r2\

# Install gosu, which enables us to run Ansible as the user who started the container
                       gosu@testing=1.17-r0\
                       sudo=1.9.12-r1\

# Install ssh
                       openssh-client=9.0_p1-r4\
                       openssh-sftp-server=9.0_p1-r4\
                       openssh=9.0_p1-r4\
                       sshpass=1.09-r0\ &&\

# Python is Python3
    ln -s python3 /usr/bin/python &&\

# Install some required python modules which need compiling
    apk add --no-cache gcc=11.2.1_git20220219-r2\
                       musl=1.2.3-r3\
                       musl-dev=1.2.3-r3\
                       musl-utils=1.2.3-r3\
                       binutils=2.38-r3\
                       libgomp=11.2.1_git20220219-r2\
                       libatomic=11.2.1_git20220219-r2\
                       pkgconf=1.8.1-r0\
                       libgcc=11.2.1_git20220219-r2\
                       mpfr4=4.1.0-r0\
                       mpc1=1.2.1-r0\
                       libstdc++=11.2.1_git20220219-r2\
                       zlib-dev=1.2.12-r3\
                       python3-dev=3.10.13-r0\
                       openssl-dev=1.1.1w-r1\
                       libffi-dev=3.4.2-r1\
                       libxml2-dev=2.9.14-r2\
                       libxslt-dev=1.1.35-r0\ &&\

    pip install asn1crypto==1.5.1\
                cffi==1.16.0\
                cryptography==41.0.7\
                enum34==1.1.10\
                idna==3.6\
                ipaddress==1.0.23\
                ncclient==0.6.15\
                paramiko==3.4.0\
                pycparser==2.21\
                pycrypto==2.6.1\
                six==1.16.0 &&\

    apk del --no-cache gcc\
                       python3-dev\
                       musl-dev\
                       binutils\
                       libgomp\
                       libatomic\
                       pkgconf\
                       libgcc\
                       mpfr4\
                       mpc1\
                       libstdc++\
                       zlib-dev\
                       python3-dev\
                       openssl-dev\
                       libffi-dev\
                       libxml2-dev\
                       libxslt-dev &&\

 # Install docker command and ensure it's always executed w/ sudo
    curl -fL -o /tmp/docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz" &&\
    tar -xf /tmp/docker.tgz --exclude docker/docker?* -C /tmp &&\
    mv /tmp/docker/docker /tmp/docker/real-docker &&\
    mv /tmp/docker/* /usr/local/bin/ &&\
    rm -rf /tmp/docker /tmp/docker.tgz &&\
    echo "#!/usr/bin/env bash" > /usr/local/bin/docker &&\
    echo 'sudo /usr/local/bin/real-docker "$@"' >> /usr/local/bin/docker &&\
    chmod +x /usr/local/bin/docker
