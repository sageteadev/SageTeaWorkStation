FROM postgres:14.2

ARG DEBIAN_FRONTEND=noninteractive

#Install dbus
RUN apt-get update && apt install -y dbus apache2 

# Install packages
RUN apt-get update && apt-get install -y apt-utils curl git wget bash build-essential apt-transport-https python3-pip python3-venv python3-dev gnupg g++ unzip zip net-tools sudo

COPY overlay/etc/apache2/* /etc/apache2/
COPY overlay/etc/init.d/* /etc/init.d/
COPY overlay/etc/ssl/* /etc/ssl/
COPY overlay/opt/*  /opt/
COPY overlay/usr/local/* /usr/local/

EXPOSE 7001 8070 8080 8087 8088 5432

#ENTRYPOINT ["sh","/opt/sageteacloudsq/SqueakVM/squeak -nodisplay -nosound -encoding UTF-8 /opt/sageteacloudsq/SageTeaCloud.image -cwd /home/%i -doit "SageTeaManager startServerLogging; launch ""]
#CMD ["postgres"]