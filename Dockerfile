FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y apache2 curl git wget
# Get SageTeaCloud from repo and install
RUN wget -q -O /tmp/sageteacloud64-3.916.amd64.deb https://repo.sagetea.ai/repo/amd64/sageteacloud64-3.916.amd64.deb \
&& dpkg -i /tmp/sageteacloud64-3.916.amd64.deb \
&& rm /tmp/sageteacloud64-3.916.amd64.deb
