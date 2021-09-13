FROM ubuntu:20.10


ENV REED_API_KEY ''
ENV BUCKET_NAME ''
ENV DB_IP ''
ENV DB_NAME ''
ENV DB_PASS ''
ENV DB_HOST ''

RUN apt-get -y update

RUN apt-get -y install curl jq apt-transport-https ca-certificates gnupg postgresql-client gawk

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

WORKDIR /keys
COPY ./keys/gcp.json key.json
RUN gcloud auth activate-service-account --key-file=key.json

WORKDIR /scripts
COPY ./scripts/config.sql config.sql
COPY ./extract.sh extract.sh
COPY ./scripts/transforms.awk transforms.awk
COPY ./scripts/generate_insert_statements.awk generate_insert_statements.awk

WORKDIR /
RUN mkdir data

CMD ["/scripts/extract.sh"]



