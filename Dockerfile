FROM elixir:latest

RUN mkdir src
WORKDIR src

RUN apt-get -y update
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get -y install inotify-tools git nodejs npm
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY mix.exs ./
COPY mix.lock ./
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get --force --only prod

RUN mkdir config
ADD config/prod.exs config/prod.exs
ADD config/dev.exs config/dev.exs
ADD config/config.exs config/config.exs
COPY lib/ ./lib/

RUN MIX_ENV=prod mix compile

COPY assets/ ./assets/
COPY priv/ ./priv/

RUN rm -rf priv/static/
RUN rm -rf assests/node_modules
RUN cd assets && npm install && npm run deploy
RUN MIX_ENV=prod mix phx.digest
RUN rm -rf assests/node_modules
