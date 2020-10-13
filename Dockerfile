FROM openjdk:8u242-jdk-buster

ARG COMMIT_FULL_HASH
ARG VIEWER_PATH
ARG XTF_PATH
ARG SERVICES_PATH
ARG SERVICES_KEY

ENV ANT_URL 'https://mirrors.estointernet.in/apache//ant/binaries/apache-ant-1.10.9-bin.tar.bz2'
ENV ANT_URL_SHA512 'e74f490c64addfb5040ee80d38d4de3057b8fc7c58dd627dd77883964fd41edfc208230f45ee5500d70fc07a2f81a1d8d069a3b70ed6055c2975c49d753b73bc'

# Ensure we have a commit hash set
RUN [ "${COMMIT_FULL_HASH}" != "" ] || (echo 'Error: COMMIT_FULL_HASH build arg is not set'; exit 1)

RUN echo "$ANT_URL_SHA512 -" > /tmp/apache-ant.tar.bz2.sha512 && \
  curl -fLs "$ANT_URL" | tee /tmp/apache-ant.tar.bz2 | sha512sum -c /tmp/apache-ant.tar.bz2.sha512
RUN mkdir -p /opt/apache-ant && \
  tar -C /opt/apache-ant --strip-components 1 -xf /tmp/apache-ant.tar.bz2

COPY . /var/src/xtf/

RUN sed -i "s/\$VIEWER_PATH/${VIEWER_PATH}/g" /var/src/xtf/conf/local.conf
RUN sed -i "s/\$XTF_PATH/${XTF_PATH}/g" /var/src/xtf/conf/local.conf
RUN sed -i "s/\$SERVICES_PATH/${SERVICES_PATH}/g" /var/src/xtf/conf/local.conf
RUN sed -i "s/\$SERVICES_KEY/${SERVICES_KEY}/g" /var/src/xtf/conf/local.conf

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
