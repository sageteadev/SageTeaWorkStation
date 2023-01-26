FROM jrei/systemd-ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Print Machinne name
RUN whoami

# Enable systemd.
RUN apt-get update ; \
    apt-get install -y systemd systemd-sysv ; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ; \
    cd /lib/systemd/system/sysinit.target.wants/ ; \
    ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 ; \
    rm -f /lib/systemd/system/multi-user.target.wants/* ; \
    rm -f /etc/systemd/system/*.wants/* ; \
    rm -f /lib/systemd/system/local-fs.target.wants/* ; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* ; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* ; \
    rm -f /lib/systemd/system/basic.target.wants/* ; \
    rm -f /lib/systemd/system/anaconda.target.wants/* ; \
    rm -f /lib/systemd/system/plymouth* ; \
    rm -f /lib/systemd/system/systemd-update-utmp*

# Install packages
RUN apt-get update && apt-get install -y apache2 curl git wget bash build-essential apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo
RUN apt install -y postgresql
# Copy Overlay files
#COPY overlay/postgresql.conf /etc/postgresql/14/main/
#COPY overlay/pg_hba.conf /etc/postgresql/14/main/pg_hba.conf
#RUN chmod +r /etc/postgresql/14/main/pg_hba.conf
RUN service postgresql start

# Get package from 
RUN wget -q -O /tmp/sageteacloud64-3.916.amd64.deb https://repo.sagetea.ai/repo/amd64/sageteacloud64-3.917.amd64.deb \
&& dpkg -i /tmp/sageteacloud64-3.916.amd64.deb \
&& rm /tmp/sageteacloud64-3.916.amd64.deb

EXPOSE 7001 8070 8080 8087 8088

#ENTRYPOINT ["bash","/usr/local/bin/SageTeaCloudSQ.sh"]
#CMD [ "/usr/local/bin/SageTeaCloudSQ.sh" ]