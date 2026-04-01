FROM ruby:3-alpine

ARG CFNDSL_VERSION="1.7.3"
ARG AWS_SPEC_VERSION="7.1.0"

# Upgrade OS packages (fixes libcrypto3/libssl3 CRITICAL, musl HIGH CVEs)
RUN apk upgrade --no-cache

# Patch bundled Ruby gem CVEs (rexml CVE-2024-49761, uri CVE-2025-61594)
RUN gem update rexml uri --no-document

RUN apk add --no-cache bash groff less python3 py3-pip git zip && \
    pip3 install --no-cache-dir --break-system-packages awscli && \
    adduser -D -u 1000 gocd

# Install gems and download spec as root (/usr/local/bundle is root-owned in ruby:3-alpine)
RUN gem install cfndsl -v $CFNDSL_VERSION --no-document && \
    gem install aws-sdk --no-document

RUN cfndsl -u $AWS_SPEC_VERSION

# Switch to non-root user for runtime only
USER gocd

WORKDIR /home/gocd/templates

ENTRYPOINT ["/usr/local/bundle/bin/cfndsl"]

CMD ["--help"]
