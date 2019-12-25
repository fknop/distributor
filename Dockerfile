FROM elixir:1.9.4-alpine as installer

RUN apk add --update build-base

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs ./
COPY mix.lock ./
COPY config config

RUN mix do deps.get, deps.compile


FROM elixir:1.9.4-alpine as builder

RUN mkdir /app
WORKDIR /app


RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY --from=installer /app/mix.lock .
COPY --from=installer /app/mix.exs .
COPY --from=installer /app/deps deps

COPY config config
COPY priv priv
COPY lib lib

RUN mix do compile

COPY rel rel
RUN mix release

FROM alpine:3.9 as application

RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=builder /app/_build/prod/rel/distributor ./

RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
ENV DISTRIBUTOR_ENV=production

CMD trap 'exit' INT; /app/bin/distributor start

