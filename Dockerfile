FROM ubuntu:20.04

RUN apt-get update && apt-get install -y apache2 curl git wget
