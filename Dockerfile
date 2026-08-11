FROM ruby:3-alpine

ARG CFNDSL_VERSION="1.9.5"
ARG AWS_SPEC_VERSION="260.0.0"

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

# Download the CloudFormation resource specification into the RUNTIME user's home.
# cfndsl resolves $HOME/.cfndsl/resource_specification.json and silently falls back to the
# spec bundled inside the gem when that path is missing (lib/cfndsl/globals.rb). Running this
# as root writes /root/.cfndsl, which the gocd runtime user never reads — so the pinned version
# had no effect and the image used whatever spec the gem shipped. Write it to /home/gocd and
# chown it, then assert the version so a silent fallback can't return.
RUN HOME=/home/gocd cfndsl -u $AWS_SPEC_VERSION && \
    chown -R gocd:gocd /home/gocd/.cfndsl && \
    test "$(ruby -rjson -e 'puts JSON.parse(File.read("/home/gocd/.cfndsl/resource_specification.json"))["ResourceSpecificationVersion"]')" = "$AWS_SPEC_VERSION"

# Switch to non-root user for runtime only
USER gocd

WORKDIR /home/gocd/templates

ENTRYPOINT ["/usr/local/bundle/bin/cfndsl"]

CMD ["--help"]
