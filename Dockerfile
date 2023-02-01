FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Enable systemd.
RUN apt-get update ; \
    apt-get install -y systemd systemd-sysv runit-systemd

# Install packages
RUN apt-get update && apt-get install -y apt-utils apache2 curl git wget bash build-essential apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo
RUN apt install -y postgresql
# Install deb package
RUN wget -q -O /tmp/*.deb https://repo.sagetea.ai/repo/amd64/*.deb \
  && dpkg -i /tmp/*.deb \
  && rm /tmp/*.deb

# Restart Services if wont crash
RUN service apache2 restart
RUN service postgresql restart

EXPOSE 7001 8070 8080 8087 8088 5432

ENTRYPOINT ["bash","/usr/local/bin/SageTeaCloudSQ.sh --name=sdefault --webport=8070 --license=OFM42-DA-AC-AD --password=5Vo4Qz_Uhg-BcCh"]
#CMD [ "/usr/local/bin/SageTeaCloudSQ.sh" ]