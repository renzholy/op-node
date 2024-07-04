FROM golang:bookworm AS build
WORKDIR /app
ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.7.7
ENV COMMIT=f8143c8cbc4cc0c83922c53f17a1e47280673485
RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
  git switch -c branch-$VERSION && \
  bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'
RUN cd op-node && \
  make VERSION=$VERSION op-node

FROM debian:bookworm-slim
WORKDIR /app
RUN apt-get install -y ca-certificates openssl
COPY --from=build /app/op-node/bin/op-node ./
ENTRYPOINT ["./op-node"]
