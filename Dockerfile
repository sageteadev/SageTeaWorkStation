FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Enable systemd.
RUN apt-get update ; \
    apt-get install -y systemd systemd-sysv runit-systemd

# Install packages
RUN apt-get update && apt-get install -y apache2 curl git wget bash build-essential apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo
RUN apt install -y postgresql
# Copy Overlay files we are gonna try to make it run without systemd
COPY overlay/etc/apache2/sites-available/sagetea-ssl.conf /etc/apache2/sites-avaible/sagetea-ssl.conf
COPY overlay/etc/apache2/sites-available/sagetea.conf /etc/apache2/sites-avaible/sagetea.conf
COPY overlay/etc/ssl/sagetea-ssl.crt /etc/ssl/sagetea-ssl.crt
COPY overlay/etc/ssl/sagetea-ssl.key /etc/ssl/sagetea-ssl.key
COPY overlay/opt/* /opt/
COPY overlay/usr/local/bin/* /usr/local/bin/
# Add Tim Override to postgresql
COPY overlay/sagetea.conf /etc/postgresql/14/main/conf.d/sagetea.conf
# Restart Services if wont crash
RUN service apache2 restart
RUN service postgresql restart
RUN mkdir /home/sdefault

EXPOSE 7001 8070 8080 8087 8088

ENTRYPOINT ["bash","/usr/local/bin/SageTeaCloudSQ.sh --name=sdefault --webport=8070 --license=OFM42-DA-AC-AD --password=5Vo4Qz_Uhg-BcCh"]
#CMD [ "/usr/local/bin/SageTeaCloudSQ.sh" ]