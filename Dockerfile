FROM openjdk:8u242-jdk-buster

ARG COMMIT_FULL_HASH

ENV ANT_URL 'https://archive.apache.org/dist/ant/binaries/apache-ant-1.9.15-bin.tar.bz2'
ENV ANT_URL_SHA512 '474617a61e6995ecdb4de974dd7f6303d980d5afe96852e8d09f0c22434274700f3f7900e2c737fe1f395e1f8b8e1d8baf003d15607efe9aec1f7d63b5785e29'

# Ensure we have a commit hash set
RUN [ "${COMMIT_FULL_HASH}" != "" ] || (echo 'Error: COMMIT_FULL_HASH build arg is not set'; exit 1)

RUN echo "$ANT_URL_SHA512 -" > /tmp/apache-ant.tar.bz2.sha512 && \
  curl -fLs "$ANT_URL" | tee /tmp/apache-ant.tar.bz2 | sha512sum -c /tmp/apache-ant.tar.bz2.sha512
RUN mkdir -p /opt/apache-ant && \
  tar -C /opt/apache-ant --strip-components 1 -xf /tmp/apache-ant.tar.bz2

COPY . /var/src/xtf/

RUN cd /var/src/xtf/WEB-INF && /opt/apache-ant/bin/ant dist && \
  mkdir /tmp/xtf && \
  unzip -qd /tmp/xtf /var/src/xtf/WEB-INF/dist/xtf-*.war && \
  rm /tmp/xtf/bin/*.bat

FROM tomcat:9.0.30-jdk11-openjdk

ARG COMMIT_FULL_HASH

LABEL org.opencontainers.image.title="CUDL XTF"
LABEL org.opencontainers.image.description="The XTF search engine for Cambridge Digital Library (https://cudl.lib.cam.ac.uk)."
LABEL org.opencontainers.image.url="https://bitbucket.org/CUDL/cudl-xtf"
LABEL org.opencontainers.image.source="https://bitbucket.org/CUDL/cudl-xtf"
LABEL org.opencontainers.image.revision=$COMMIT_FULL_HASH
LABEL maintainer="https://bitbucket.org/CUDL/"

COPY --from=0 /tmp/xtf/ /opt/xtf/
COPY ./docker/textIndexer.conf /opt/xtf/conf/textIndexer.conf
RUN ln -s /opt/xtf /usr/local/tomcat/webapps/ROOT

ENV PATH /opt/xtf/bin:$PATH
