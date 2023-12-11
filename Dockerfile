FROM golang:alpine AS build

WORKDIR /src
RUN apk --no-cache add git
RUN git clone https://codeberg.org/gothub/gothub .

RUN go mod download
RUN GOOS=linux GOARCH=$TARGETARCH go build -o /src/gothub

FROM scratch as bin

WORKDIR /app
COPY --from=build /usr/share/ca-certificates /usr/share/ca-certificates
COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /src/gothub .
COPY --from=build /src/views ./views
COPY --from=build /src/public ./public

ENV DOCKER true
ENV GOTHUB_SETUP_COMPLETE true
EXPOSE 3000

CMD ["/app/gothub", "serve"]