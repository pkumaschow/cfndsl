FROM ruby:3-alpine

ARG CFNDSL_VERSION="1.7.3"
ARG AWS_SPEC_VERSION="7.1.0"

# Cache-bust the apk-upgrade layer so each CI build pulls the latest
# Alpine security patches (CI passes APK_REFRESH=${{ github.run_id }}).
ARG APK_REFRESH=daily

# Upgrade OS packages (fixes libcrypto3/libssl3 CRITICAL, musl HIGH CVEs)
RUN apk upgrade --no-cache

# Patch bundled Ruby gem CVEs:
#   rexml      CVE-2024-49761
#   uri        CVE-2025-61594
#   erb        CVE-2026-41316   (4.0.4.1 has a native extension — needs build-base + ruby-dev)
#   net-imap   CVE-2026-42246, CVE-2026-42256
#
# `gem update` installs the new versions under /usr/local/bundle/, but Ruby's
# bundled default/system gemspecs in /usr/local/lib/ruby/gems/.../specifications/
# (and /specifications/default/) are left behind — SCA scanners (Docker Scout,
# trivy) still flag those old gemspec files. Remove the stale ones so reports
# are clean. Ruby itself prefers the higher installed version at require time.
RUN apk add --no-cache --virtual .gem-build-deps build-base ruby-dev && \
    gem update rexml uri net-imap --no-document && \
    gem install erb -v ">= 4.0.4.1, < 5.0" --no-document && \
    RUBY_GEM_DIR=$(ruby -e 'puts Gem.default_dir') && \
    rm -f "$RUBY_GEM_DIR"/specifications/default/erb-*.gemspec && \
    rm -f "$RUBY_GEM_DIR"/specifications/net-imap-*.gemspec && \
    apk del .gem-build-deps

# urllib3>=2.7.0 pinned to fix CVE-2026-44431, CVE-2026-44432 (pulled in as awscli dep)
RUN apk add --no-cache bash groff less python3 py3-pip git zip && \
    pip3 install --no-cache-dir --break-system-packages awscli 'urllib3>=2.7.0' && \
    pip3 install --no-cache-dir --break-system-packages --upgrade wheel setuptools && \
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
