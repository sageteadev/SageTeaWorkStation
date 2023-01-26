FROM jrei/systemd-ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Enable systemd.
RUN apt-get update ; \
    apt-get install -y systemd systemd-sysv runit-systemd

# Install packages
RUN apt-get update && apt-get install -y apache2 curl git wget bash build-essential apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo
RUN apt install -y postgresql
# Copy Overlay files
#COPY overlay/postgresql.conf /etc/postgresql/14/main/
#COPY overlay/pg_hba.conf /etc/postgresql/14/main/pg_hba.conf
#RUN chmod +r /etc/postgresql/14/main/pg_hba.conf
RUN service postgresql start
RUN mkdir /home/sdefault

# Get package from 
RUN wget -q -O /tmp/sageteacloud64-3.916.amd64.deb https://repo.sagetea.ai/repo/amd64/sageteacloud64-3.917.amd64.deb \
&& dpkg -i /tmp/sageteacloud64-3.916.amd64.deb \
&& rm /tmp/sageteacloud64-3.916.amd64.deb

EXPOSE 7001 8070 8080 8087 8088

#ENTRYPOINT ["bash","/usr/local/bin/SageTeaCloudSQ.sh"]
#CMD [ "/usr/local/bin/SageTeaCloudSQ.sh" ]