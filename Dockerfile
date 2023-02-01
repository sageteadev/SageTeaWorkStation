FROM postgres:latest

ARG DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get update && apt-get install -y apt-utils apache2 curl git wget bash build-essential apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo
#Jus for case create the db
RUN sudo -u postgres bash -c "psql -c \"DROP DATABASE $username;\""
RUN sudo -u postgres bash -c "psql -c \" DROP USER $username;\""
RUN sudo -u postgres bash -c "psql -c \"CREATE USER $username;\""
RUN sudo -u postgres bash -c "psql -c \"ALTER USER $username with password 'ghQw9f_98hjm';\""
RUN sudo -u postgres bash -c "psql -c \"ALTER USER $username with superuser;\""
RUN sudo -u postgres bash -c "psql -c \"ALTER USER $username with createrole;\""
RUN sudo -u postgres bash -c "psql -c \"ALTER USER $username with createdb;\""
RUN sudo -u postgres createdb $username
RUN sudo -u postgres bash -c "psql -c \"ALTER DATABASE $username OWNER TO $username;\""
RUN systemctl daemon-reload
# Install deb package
RUN wget -O /tmp/sageteacloud64-3.936.amd64.deb https://repo.sagetea.ai/repo/amd64/sageteacloud64-3.936.amd64.deb \
  && dpkg -i /tmp/sageteacloud64-3.936.amd64.deb \
  && rm /tmp/sageteacloud64-3.936.amd64.deb
# Restart Service
RUN systemctl enable sageteacloudsq@$username.service

# Restart Services if wont crash
RUN service apache2 restart
RUN service postgresql restart

EXPOSE 7001 8070 8080 8087 8088 5432

#ENTRYPOINT ["bash","/usr/local/bin/SageTeaCloudSQ.sh --name=sdefault --webport=8070 --license=OFM42-DA-AC-AD --password=5Vo4Qz_Uhg-BcCh"]
CMD [ "/sbin/init" ]