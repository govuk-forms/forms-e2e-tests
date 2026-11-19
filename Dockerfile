ARG ALPINE_VERSION=3.24
ARG RUBY_VERSION=3.4.13

ARG DOCKER_IMAGE_DIGEST=sha256:9010b7942739e483ab8e359eae1190ea10af21cf7476daa41ece6f896dc8e02a

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}@${DOCKER_IMAGE_DIGEST}

RUN apk update
RUN apk upgrade --available

RUN apk add chromium chromium-chromedriver libc6-compat build-base yaml-dev aws-cli

RUN adduser -D ruby

RUN mkdir /app && chown -R ruby:ruby /app
WORKDIR /app

USER ruby

COPY --chown=ruby:ruby .ruby-version .
COPY --chown=ruby:ruby Gemfile* .

RUN bundle config set --local without development
RUN bundle install

COPY --chown=ruby:ruby . .

CMD ["bundle", "exec", "rspec"]
