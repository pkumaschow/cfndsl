FROM ruby:3-alpine3.17

ARG CFNDSL_VERSION="1.4.0"
ARG AWS_SPEC_VERSION="7.1.0"

RUN apk update

RUN apk -Uuv add bash groff less python3 py-pip && \
                pip install awscli && \
                apk add --update zip git && \
                apk add --upgrade apk-tools && \
                apk --purge -v del py-pip && \
                rm /var/cache/apk/* && \
                adduser -D -u 1000 gocd

USER gocd

RUN gem install cfndsl -v $CFNDSL_VERSION && \
                                gem install aws-sdk

RUN cfndsl -u $AWS_SPEC_VERSION

WORKDIR /home/gocd/templates

ENTRYPOINT ["/usr/local/bundle/bin/cfndsl"]

CMD ["--help"]
