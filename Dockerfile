FROM bitwalker/alpine-elixir:1.9.0

# Set exposed ports
EXPOSE 443
ENV PORT=443

COPY rel ./rel
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY .env ./.env
COPY mix.exs .
COPY mix.lock .

RUN export MIX_ENV=prod && \
    source .env && \
    mix do deps.get, distillery.release

RUN tar -xzvf _build/prod/rel/websocket/releases/0.1.0/websocket.tar.gz

USER root

CMD ./bin/websocket foreground