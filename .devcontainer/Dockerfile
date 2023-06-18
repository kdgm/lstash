ARG RUBY_VERSION=2.4.6
ARG BUNDLER_VERSION=1.17.3
ARG DISTRO_NAME=buster

FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME

LABEL maintainer="support@kerkdienstgemist.nl"

# Install dependencies specified in Aptfile
COPY Aptfile /tmp/
RUN  apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade \
  && mkdir -p /usr/share/man/man1 /usr/share/man/man7 \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    $(grep -Evh '^\s*#' /tmp/Aptfile /tmp/Aptfile.dev | xargs) \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

# Configure bundler
# ENV LANG=C.UTF-8 \
#   BUNDLE_JOBS=4 \
#   BUNDLE_RETRY=3 \
#   TZ=Europe/Amsterdam

# Store Bundler settings in the project's root
# ENV BUNDLE_APP_CONFIG=.bundle

# Uncomment this line if you want to run binstubs without prefixing with `bin/` or `bundle exec`
# ENV PATH /gem/bin:$PATH

# Upgrade RubyGems and install the latest Bundler version
ARG BUNDLER_VERSION
# gem update --system &&
RUN gem install bundler:$BUNDLER_VERSION

ENV TZ="Europe/Amsterdam"

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT commands.
ENV WORKDIR /gem
RUN mkdir -p $WORKDIR
WORKDIR $WORKDIR
