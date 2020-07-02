FROM ruby:alpine3.11

ARG CFNDSL_VERSION='1.1.1'
ARG AWS_SPEC_VERSION='7.1.0'

RUN apk update

RUN apk -Uuv add bash groff less python py-pip && \
                pip install awscli && \
                apk add --update zip git && \
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
