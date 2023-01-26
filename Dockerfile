FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y apache2 curl git wget build-essential postgresql postgresql-contrib systemd apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo
# Get SageTeaCloud from repo and install
RUN wget -q -O /tmp/sageteacloud64-3.916.amd64.deb https://repo.sagetea.ai/repo/amd64/sageteacloud64-3.917.amd64.deb \
&& dpkg -i /tmp/sageteacloud64-3.916.amd64.deb \
&& rm /tmp/sageteacloud64-3.916.amd64.deb

# Copy Overlay files
COPY overlay/postgresql.conf /etc/postgresql/14/main/
COPY overlay/pg_hba.conf /etc/postgresql/14/main/pg_hba.conf

# Change Persmission on Files
RUN sudo chmod 700 /etc/postgresql/14/main/pg_hba.conf
RUN sudo chown postgres:postgres /etc/postgresql/14/main/pg_hba.conf

# Enable Services
RUN sudo systemctl enable sageteacloudsq@.service
RUN sudo systemctl enable unit-status-mail@.service
RUN sudo systemctl restart postgresql.service

EXPOSE 7001 8070 8080 8087 8088

ENTRYPOINT ["sh","/usr/local/bin/SageTeaCloudSQ.sh"]
CMD [ "/usr/local/bin/SageTeaCloudSQ.sh" ]