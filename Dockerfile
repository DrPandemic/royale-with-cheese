FROM elixir:latest

RUN mkdir src
WORKDIR src

COPY mix.exs ./
COPY mix.lock ./
COPY assets/ ./assets/
COPY priv/ ./priv/
RUN mkdir config
ADD config/prod.exs config/prod.exs
ADD config/dev.exs config/dev.exs
ADD config/config.exs config/config.exs
COPY lib/ ./lib/

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get -y update
RUN apt-get -y install inotify-tools git nodejs npm
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get --force
RUN mix deps.compile --force
