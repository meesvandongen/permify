# Step 1: Builder
FROM golang:1.21-alpine3.18@sha256:d8b99943fb0587b79658af03d4d4e8b57769b21dcf08a8401352a9f2a7228754 as permify-builder
WORKDIR /go/src/app
RUN apk update && apk add --no-cache git
COPY . .
RUN CGO_ENABLED=0 go build -v ./cmd/permify/

# Step 2: Final
FROM cgr.dev/chainguard/static:latest@sha256:37200bd74dac036a7a40f1984eefa2123d0705540daaeda6b1faee727db66726
COPY --from=ghcr.io/grpc-ecosystem/grpc-health-probe:v0.4.19 /ko-app/grpc-health-probe /usr/local/bin/grpc_health_probe
COPY --from=permify-builder /go/src/app/permify /usr/local/bin/permify
ENV PATH="$PATH:/usr/local/bin"
ENTRYPOINT ["permify"]