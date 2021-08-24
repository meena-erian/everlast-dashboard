FROM node:12.19.0-slim AS js-builder

WORKDIR /usr/src/app/

COPY package.json yarn.lock ./
COPY packages packages

RUN npx browserslist@latest --update-db

RUN yarn install --pure-lockfile

COPY Gruntfile.js tsconfig.json .eslintrc .editorconfig .browserslistrc .prettierrc.js ./
COPY public public
COPY tools tools
COPY scripts scripts
COPY emails emails

ENV NODE_ENV production

RUN yarn build

FROM golang:1.15.1 AS go-builder

WORKDIR /src/grafana

COPY go.mod go.sum ./

RUN go mod verify

COPY build.go package.json ./
COPY pkg pkg/

RUN go run build.go build

FROM ubuntu:20.04

LABEL maintainer="Grafana team <hello@grafana.com>"
EXPOSE 3000

ARG GF_UID="472"
ARG GF_GID="472"

ENV PATH="/usr/share/grafana/bin:$PATH" \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

WORKDIR $GF_PATHS_HOME

COPY conf conf

# curl should be part of the image
RUN apt-get update && apt-get install -y ca-certificates curl

RUN mkdir -p "$GF_PATHS_HOME/.aws" && \
  addgroup --system --gid $GF_GID grafana && \
  adduser --uid $GF_UID --system --ingroup grafana grafana && \
  mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
             "$GF_PATHS_PROVISIONING/dashboards" \
             "$GF_PATHS_PROVISIONING/notifiers" \
             "$GF_PATHS_LOGS" \
             "$GF_PATHS_PLUGINS" \
             "$GF_PATHS_DATA" && \
    cp conf/sample.ini "$GF_PATHS_CONFIG" && \
    cp conf/ldap.toml /etc/grafana/ldap.toml && \
    chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING" && \
    chmod -R 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING"

COPY --from=go-builder /src/grafana/bin/linux-amd64/grafana-server /src/grafana/bin/linux-amd64/grafana-cli bin/
COPY --from=js-builder /usr/src/app/public public
COPY --from=js-builder /usr/src/app/tools tools
COPY packaging/docker/run.sh /

USER grafana
COPY grafana.db /var/grafana.db
ENTRYPOINT [ "/run.sh" ]
