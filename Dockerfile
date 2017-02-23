###################################################
# Dockerfile for Long Ranger
###################################################

# Based on...
FROM centos:7

# File Author / Maintainer
MAINTAINER Eddie Belter <ebelter@wustl.edu>

# Install some utilities
RUN yum install -y \
	file \
	git \
	sssd-client \
	which \
	unzip

# Install bcl2fastq
RUN cd /tmp/ && \
	git clone git://git/bcl2fastq.git --branch v2.17.1 --single-branch bcl2fastq && \
	cd bcl2fastq/ && \
	yum -y --nogpgcheck localinstall bcl2fastq2-v2.17.1.14-Linux-x86_64.rpm && \
	cd /tmp/ && \
	rm -rf bcl2fastq/

# Set longranger version and install
ENV LONGRANGER_VERSION 2.1.3
RUN cd /tmp/ && \
	git clone git://git/10x-genomics-longranger --branch "v${LONGRANGER_VERSION}" --single-branch longranger && \
	cd longranger && \
	cp "longranger-${LONGRANGER_VERSION}.tar.gz" /opt/ && \
	cd /opt/ && \
	tar zxf "longranger-${LONGRANGER_VERSION}.tar.gz" && \
	rm -f "longranger-${LONGRANGER_VERSION}.tar.gz" /longranger

# Shell script for CMD to setup ENV
RUN mkdir /opt/bin/

# Copy longranger entry scripts
COPY longranger /opt/bin/
RUN chmod 777 /opt/bin/longranger

# Copy martian lsf template and chmod so users can customize jobmanager templates
COPY lsf.template "/opt/longranger-${LONGRANGER_VERSION}/martian-cs/2.1.2/jobmanagers"
RUN chmod 777 "/opt/longranger-${LONGRANGER_VERSION}/martian-cs/2.1.2/jobmanagers"
RUN chmod 666 "/opt/longranger-${LONGRANGER_VERSION}/martian-cs/2.1.2/jobmanagers/*.template"

# Entrypoint is the longranger wrapper scipt
ENTRYPOINT ["/opt/bin/longranger"]