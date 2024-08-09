FROM golang:bookworm AS build
WORKDIR /app
ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.9.0
RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
  git switch -c branch-$VERSION && \
  bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'
RUN cd op-node && \
  make VERSION=$VERSION op-node

FROM debian:bookworm-slim
WORKDIR /app
RUN apt-get update && \
  apt-get install -y ca-certificates openssl && \
  rm -rf /var/lib/apt/lists
COPY --from=build /app/op-node/bin/op-node ./
ENTRYPOINT ["./op-node"]
