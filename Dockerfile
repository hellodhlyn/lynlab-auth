### Builder
FROM golang:1.18-alpine as builder
RUN apk update && apk add git && apk add ca-certificates && apk add tzdata

WORKDIR /usr/src/app
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-s' -o dist/server cmd/server/main.go


### Make executable image
FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /usr/src/app/dist /

EXPOSE 8080
CMD [ "/server" ]
