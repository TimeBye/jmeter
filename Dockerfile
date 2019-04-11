FROM adoptopenjdk/openjdk8-openj9:jdk8u202-b08_openj9-0.12.1

# Modify timezone
ENV LANG=C.UTF-8 \
    TZ="Asia/Shanghai" \
    TINI_VERSION="v0.18.0" \
    JMETER_VERSION="5.1.1" \
    JPGC_CASUTG_VERSION="2.8"
ENV JMETER_HOME="/opt/apache-jmeter-${JMETER_VERSION}"
ENV	JMETER_BIN="${JMETER_HOME}/bin"
ENV PATH="${PATH}:${JMETER_BIN}"

# Add mirror source
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i 's http://archive.ubuntu.com http://mirrors.aliyun.com g' /etc/apt/sources.list

# Install base packages
RUN apt-get update && apt-get install -y \
        vim \
        tar \
        zip \
        curl \
        wget \
        gzip \
        unzip \
        bzip2 \
        netcat \
        locales \
        xz-utils \
        net-tools \
        fontconfig \
        openssh-client \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    wget -qO /usr/local/bin/tini \
       "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64" && \
    chmod +x /usr/local/bin/tini && \
	wget -qO "apache-jmeter-${JMETER_VERSION}.tgz" \
        "http://mirrors.tuna.tsinghua.edu.cn/apache//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz" && \
	mkdir -p /opt && \
	tar -xzf "apache-jmeter-${JMETER_VERSION}.tgz" -C /opt && \
	rm -rf "apache-jmeter-${JMETER_VERSION}.tgz" && \
    wget -qO "jpgc-casutg-${JPGC_CASUTG_VERSION}.zip" \
        "https://jmeter-plugins.org/files/packages/jpgc-casutg-${JPGC_CASUTG_VERSION}.zip" && \
	unzip "jpgc-casutg-${JPGC_CASUTG_VERSION}.zip" -d "${JMETER_HOME}" && \
	rm -rf "jpgc-casutg-${JPGC_CASUTG_VERSION}.zip"

ENTRYPOINT ["tini", "--"]