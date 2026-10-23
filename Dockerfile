ARG ALPINE_VERSION=3.24
ARG RUBY_VERSION=3.4.12

ARG DOCKER_IMAGE_DIGEST=sha256:TODO-replace-with-ruby-3.4.12-alpine3.24-digest

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
