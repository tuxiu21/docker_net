FROM alpine:3.20

RUN apk add --no-cache openvpn curl bind-tools

COPY entrypoint.sh /entrypoint.sh
COPY up.sh /up.sh
RUN chmod +x /entrypoint.sh /up.sh

ENTRYPOINT ["/entrypoint.sh"]
