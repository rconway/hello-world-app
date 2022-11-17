FROM ubuntu

RUN apt-get update && apt-get -y install curl

WORKDIR /app

COPY ./app.sh /app

ENV PATH="/app:${PATH}"

ENTRYPOINT [ "app.sh" ]
