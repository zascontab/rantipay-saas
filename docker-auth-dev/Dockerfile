FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY auth_server.go .
RUN go build -o auth_server auth_server.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/auth_server /app/
ENV SERVICE_NAME="auth-service"
EXPOSE 80
CMD ["/app/auth_server"]
