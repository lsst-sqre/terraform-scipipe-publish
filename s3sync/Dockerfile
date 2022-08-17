FROM almalinux:8

#ARG AWSCLI_VER=1.25.53
# I clearly see the 1.25 series on Pypi, but pip3 won't find anything later
# than 1.24.10 (as of 17 Aug 2022).  Don't know why.
# 1.24.10 was released May 27, 2022
ARG AWSCLI_VER=1.24.10

USER root
RUN yum update -y
RUN yum install -y python3.9 python3-pip
RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install awscli=="${AWSCLI_VER}" --upgrade --no-cache-dir

RUN yum -y swap fakesystemd systemd
RUN yum -y install systemd-libs
# XXX masking these units seems to no longer be necessary?
#RUN systemctl mask dev-mqueue.mount dev-hugepages.mount \
#    systemd-remount-fs.service sys-kernel-config.mount \
#    sys-kernel-debug.mount sys-fs-fuse-connections.mount \
#    display-manager.service systemd-logind.service
RUN systemctl disable graphical.target; systemctl enable multi-user.target
VOLUME ["/sys/fs/cgroup"]

COPY scripts/s3sync.timer /etc/systemd/system/s3sync.timer
COPY scripts/s3sync.service /etc/systemd/system/s3sync.service
RUN systemctl enable s3sync.timer

COPY scripts/s3sync /usr/local/bin/s3sync
RUN chmod a+x /usr/local/bin/s3sync

RUN useradd s3sync

CMD  ["/usr/lib/systemd/systemd"]
