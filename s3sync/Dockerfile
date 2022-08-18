FROM almalinux/almalinux:8

#ARG AWSCLI_VER=1.25.53
# I clearly see the 1.25 series on Pypi, but pip3 won't find anything later
# than 1.24.10 (as of 17 Aug 2022).  Don't know why.
# 1.24.10 was released May 27, 2022
ARG AWSCLI_VER=1.24.10

USER root
RUN yum update -y
RUN yum install -y python3.9 python3-pip cronie
RUN pip3 install awscli=="${AWSCLI_VER}" --upgrade --no-cache-dir

COPY scripts/crontab /etc/crontab
COPY scripts/s3sync /usr/local/bin/s3sync
RUN chmod a+x /usr/local/bin/s3sync

CMD  ["/usr/sbin/crond", "-n"]
