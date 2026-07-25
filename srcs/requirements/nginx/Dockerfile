FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends nginx openssl gettext-base && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /tmp/nginx.conf

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
