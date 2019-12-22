### Builder Stage
FROM elixir:1.9-alpine AS builder

ENV MIX_ENV=prod

WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

COPY mix.exs .
COPY mix.lock .
RUN mix deps.get --only prod
RUN mix deps.compile --only prod

COPY . .
RUN mix compile
RUN mix release

### Application Stage
FROM alpine:3.11 AS app
RUN apk add --update bash openssl
RUN rm -rf /var/cache/apk/*

ENV MIX_ENV=prod

RUN adduser -D -h /home/app app
WORKDIR /home/app

COPY --from=builder /app/_build/prod/rel/luppiter_auth .
COPY docker-entrypoint.sh .
RUN chown -R app: .
USER app

ENTRYPOINT [ "./docker-entrypoint.sh" ]
