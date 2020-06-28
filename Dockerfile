FROM golang:1.14 as build
WORKDIR /go/src/app

# Create appuser to isolate potential vulnerabilities
# See https://stackoverflow.com/a/55757473/12429735RUN
ENV USER=appuser
ENV UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

# Update ca-certificates, for final stage.
RUN apt-get update && apt-get install -y ca-certificates

# Build
RUN CGO_ENABLED=0 go get -u github.com/vmware/govmomi/vcsim

###############################################################################
# final stage
FROM scratch

# Allow container to use latest TLS certificates
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy over appuser to run as non-root
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group

# Run all commands as non-root
USER appuser:appuser

# Build arguments for consistency
ARG APPLICATION="go-executable"
ARG BUILD_RFC3339="1970-01-01T00:00:00Z"
ARG COMMIT="local"
ARG DESCRIPTION="no description"
ARG VERSION="dirty"

# Labels for the container
LABEL org.opencontainers.image.ref.name="jnovack/${APPLICATION}" \
      org.opencontainers.image.created=$BUILD_RFC3339 \
      org.opencontainers.image.authors="Justin J. Novack <jnovack@gmail.com>" \
      org.opencontainers.image.documentation="https://github.com/jnovack/${APPLICATION}/README.md" \
      org.opencontainers.image.description="${DESCRIPTION}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/jnovack/${APPLICATION}" \
      org.opencontainers.image.revision=$COMMIT \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.url="https://hub.docker.com/r/jnovack/${APPLICATION}/"

# Application runs on local port
EXPOSE 443

# Copy application from build stage
COPY --from=build /go/bin/${APPLICATION} /app

# Set entrypoint to application with container defaults
ENTRYPOINT ["/app", "-logtostderr", "-l 0.0.0.0:443"]