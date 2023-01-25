FROM microsoft/nanoserver
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV NATS_VERSION="v0.9.6"

RUN Add-WindowsFeature Web-server, NET-Framework-45-ASPNET, Web-Asp-Net45 

WORKDIR c:/SageTeaWorkStation
COPY gnatsd.conf gnatsd.conf

# Expose client, management, and cluster ports
EXPOSE 8080

ENTRYPOINT ["gnatsd"]
CMD ["-c", "gnatsd.conf"]