FROM crystallang/crystal:latest

WORKDIR /app

COPY . .

RUN ["shards", "install"]

ENTRYPOINT ["sh", "start.sh"]