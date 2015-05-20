FROM ubuntu:12.04

COPY . /src

RUN cd /src && apt-get update && apt-get install -y build-essential && apt-get install -y curl && curl -sL https://deb.nodesource.com/setup | bash - && apt-get install -y nodejs && npm install && npm install -g coffee-script && rm -rf /var/lib/apt/lists/*

EXPOSE 5000

CMD cd /src && coffee index.coffee
