FROM postgres:14.2

ARG DEBIAN_FRONTEND=noninteractive

#Install systemd
RUN apt-get update && apt install -y dbus dbus-user-session

# Install packages
RUN apt-get update && apt-get install -y apt-utils apache2 curl git wget bash build-essential apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo

# Install deb package
RUN wget -N -O /tmp/sageteacloud64-3.937.amd64.deb https://repo.sagetea.ai/repo/amd64/sageteacloud64-3.937.amd64.deb \
  && dpkg -i /tmp/sageteacloud64-3.937.amd64.deb \
  && rm /tmp/sageteacloud64-3.937.amd64.deb

EXPOSE 7001 8070 8080 8087 8088 5432

ENTRYPOINT ["bash","/opt/sageteacloudsq/SqueakVM/squeak -nodisplay -nosound -encoding UTF-8 /opt/sageteacloudsq/SageTeaCloud.image -cwd /home/%i -doit "SageTeaManager startServerLogging; launch ""]
CMD ["postgres"]