FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

#Install systemd
RUN apt-get update && apt install -y systemd
# Enable systemd
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -print0 | xargs -0 rm -vf

# Install packages
RUN apt-get update && apt-get install -y apt-utils apache2 curl git wget bash build-essential apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo

# Install deb package
RUN wget -O /tmp/sageteacloud64-3.936.amd64.deb https://repo.sagetea.ai/repo/amd64/sageteacloud64-3.936.amd64.deb \
  && dpkg -i /tmp/sageteacloud64-3.936.amd64.deb \
  && rm /tmp/sageteacloud64-3.936.amd64.deb

RUN chmod 0644 /etc/systemd/system/sageteacloudsq@.service
RUN systemctl daemon-reload

EXPOSE 7001 8070 8080 8087 8088 5432

#ENTRYPOINT ["bash","/usr/local/bin/SageTeaCloudSQ.sh --name=sdefault --webport=8070 --license=OFM42-DA-AC-AD --password=5Vo4Qz_Uhg-BcCh"]
CMD [ "/sbin/init" ]