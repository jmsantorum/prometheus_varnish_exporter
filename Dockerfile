FROM golang:1.17.4 AS build-stage

# Set destination for COPY
WORKDIR /app

# Download Go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY *.go ./

RUN go test -v ./...

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o /prometheus_varnish_exporter

# Deploy the application binary into a lean image
FROM gcr.io/distroless/base-debian11 AS build-release-stage

COPY --from=build-stage /prometheus_varnish_exporter /prometheus_varnish_exporter

EXPOSE 9131

USER nonroot:nonroot

# RUN
CMD ["/prometheus_varnish_exporter"]