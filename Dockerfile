# escape=`
FROM microsoft/windowsservercore AS installer
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV ES_VERSION="5.6.2" `
    ES_SHA512="db4ec26915d2dc1673307522c168560f2ff7aa6cd3834d2d19effd398c05881b4cb2b08cbad3c8e7dd223a91ddfa2ff8401aae7ac9d69805dc1db8b88d30e393"

RUN Invoke-WebRequest -OutFile es.zip -UseBasicParsing "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$($env:ES_VERSION).zip"; `
    If ((Get-FileHash es.zip -Algorithm sha512).Hash -ne $env:ES_SHA512) {exit 1}; `
    Expand-Archive es.zip -DestinationPath C:\ ; `
    Move-Item C:\elasticsearch-$($env:ES_VERSION) C:\elasticsearch

# Elasticsearch
FROM openjdk:8-jdk-nanoserver

EXPOSE 9200 9300
WORKDIR C:\elasticsearch
CMD ".\bin\elasticsearch.bat"

COPY --from=installer C:\elasticsearch\ .
COPY .\config ./config