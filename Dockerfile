FROM bitwalker/alpine-elixir:1.9.0

# Set exposed ports
EXPOSE 443
ENV PORT=443

COPY rel ./rel
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

RUN export MIX_ENV=prod && \
    mix do deps.get, distillery.release

RUN tar -xzvf _build/prod/rel/websocket/releases/0.1.2/websocket.tar.gz

USER root

# Change MIX_ENV to prod: https://github.com/bitwalker/exrm/issues/135
CMD MIX_ENV=prod ./bin/websocket foreground