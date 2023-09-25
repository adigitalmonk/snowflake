FROM elixir:1.15.4-alpine as build

ENV MIX_ENV=prod
WORKDIR /opt/app

COPY mix.exs mix.exs
COPY mix.lock mix.lock
COPY config config
COPY lib lib

RUN apk add git && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod --force && \
    mix compile

RUN mix release

FROM elixir:1.15.4-alpine

WORKDIR /opt/app

COPY --from=build /opt/app/_build/prod/rel .

CMD ["snowflake/bin/snowflake", "start"]
