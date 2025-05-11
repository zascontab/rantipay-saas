FROM golang:1.20 as builder

WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o simple-user .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/simple-user .
EXPOSE 8000
CMD ["./simple-user"]
