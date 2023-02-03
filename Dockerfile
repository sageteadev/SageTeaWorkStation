FROM postgres:14.2

ARG DEBIAN_FRONTEND=noninteractive

#Install dbus
RUN apt-get update && apt install -y dbus dbus-user-session
#Install postrgres
RUN apt-get install postgresql-14


# Install packages
RUN apt-get update && apt-get install -y apt-utils curl git wget bash build-essential apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo
RUN echo deb https://repo.sagetea.ai/repo/amd64/jammy main > /etc/apt/sources.list

# Install deb package
RUN wget -N -O /tmp/sageteacloud64-3.939.amd64.deb https://repo.sagetea.ai/repo/amd64/sageteacloud64-3.939.amd64.deb \
  && dpkg -i /tmp/sageteacloud64-3.939.amd64.deb \
  && rm /tmp/sageteacloud64-3.939.amd64.deb

EXPOSE 7001 8070 8080 8087 8088 5432

ENTRYPOINT ["sh","/opt/sageteacloudsq/SqueakVM/squeak -nodisplay -nosound -encoding UTF-8 /opt/sageteacloudsq/SageTeaCloud.image -cwd /home/%i -doit "SageTeaManager startServerLogging; launch ""]
CMD ["postgres"]