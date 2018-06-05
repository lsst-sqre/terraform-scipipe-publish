FROM centos:7

ARG AWSCLI_VER=1.14.61

USER root
RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y python-pip
RUN pip install awscli=="${AWSCLI_VER}" --upgrade --no-cache-dir

RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
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
