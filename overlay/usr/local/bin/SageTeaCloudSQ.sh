#!/bin/bash
#v1.41
# has to be run as root in order to work. Not the best way to do things.
#Return codes:
#0    Success
#101  No arguments supplied
#102  Invalid arguments
#103  Port in use
#104  User alreasy exists
#105  Portal already deleted
#106  Python is not installed (or symlink missing)
#107  DLC file doesn't exist
#109  Invalid portal name


#set -x

#whoami

function usage () {
  echo ""
  echo "Usage: $0 [options]"
  echo "  --help :: Prints this usage"
  echo "  --default :: Use default values"
  echo "  --name={portal_name} :: Specify a portal name"
  echo "  --webport={port_number} :: Use specific web port."
  echo "  --start ::(optional) start the portal"
  echo "  --stop ::(optional) stop the portal"
  echo "  --delete ::(optional) Delete the portal"
  echo "  --dlcname :: Specify the DLC full path and name"
  echo "  --list :: List running portals"
  echo "  --password :: initial password"
  echo "  --demo :: Demo or full portal version"
  echo "  --license :: License key"

  echo ""
  echo "Example, stop portal: SageTeaCloudSQ.sh --name=sagetea01 --stop=yes"
  echo "Example, start portal: SageTeaCloudSQ.sh --name=sagetea01 --start=yes"
  echo "Example, create new portal: SageTeaCloudSQ.sh --name=sagetea01 --port=7010"
  echo "Example, create new portal with specific web port: SageTeaCloudSQ.sh --name=sagetea01 --webport=8089 --dlcname=/usr/bin/sageteacloud64/server/sageteaCloud/SageTeaCloud.dlc"
  echo "Example, create new portal using MySQL: SageTeaCloudSQ.sh --name=sagetea01 --webport=8089 --DBType=mysql"
  echo "Example, delete portal: SageTeaCloudSQ.sh --name=sagetea01 --delete=yes"
  echo "Example, List of running portals: SageTeaCloudSQ.sh --list=yes"


}



#Default
#set -o errexit -o pipefail -o noclobber -o nounset
num_of_valid_args=1
arg_index=0
portal_name=sageteaadmin
password=0
serverport=8088
DEFAULT=no
portalstart=no
portalstop=no
demo=no
DBType=psql
deleteportal=no
listportals=no
name_supplied=0
password_supplied=0
port_supplied=0
license="null"
webserverport_supplied=0
dlcName=/opt/sageteacloudsq/dlcx/OfficeManager.dlcx
num_of_args=0
LOG=/tmp/sagetea
server=$(hostname)

for i in "$@"; do

      num_of_args=$((num_of_args + 1))

      case "$i" in

    --dlcname=*)
      dlcName="${i#*=}"
    ;;

        --help=*)
            usage
            exit 101
        ;;

        --name=*)
          portal_name="${i#*=}"
          name_supplied=1
        ;;

        --delete=yes)
          deleteportal=yes
        ;;

        --stop=yes)
      echo Coming to a stop
          portalstop=yes
        ;;

        --start=yes)
          portalstart=yes
        ;;

        --list=yes)
          listportals=yes
        ;;


        --webport=*)
          webserverport="${i#*=}"
          port_supplied=1
          webserverport_supplied=1
        ;;

        --password=*)
          password="${i#*=}"
          password_supplied=1
        ;;

        --demo=*)
          demo="${i#*=}"
        ;;

        --license=*)
          license="${i#*=}"
        ;;

        --DBType=*)
          DBType="${i#*=}"
        ;;


        --delete=*)
          echo "ERROR: Invalid argument(s)"
          usage
          exit 102
        ;;

        --default=*)
          DEFAULT=yes
        ;;

        *)
      echo "ERROR: Invalid argument(s)"
          usage
          exit 102
        ;;
      esac
done

#List portals

if [[ "$listportals" == "yes" ]]; then
echo $(ps -C squeak -o pid,lstart,etime,%mem,%cpu,cmd |awk '{print $17;}' | awk '{gsub("/home/", "");print}')
exit 0
fi


#Converting portal name to lowercase
portal_name=$(echo $portal_name | tr ''[:upper:]'' ''[:lower:]'')


if [[ $num_of_args -lt 1 ]]; then
  echo "ERROR: minimum 1 argument required"
  usage
  exit 101
fi

if [[ "$deleteportal" == "yes" && $name_supplied -eq 0 ]]; then
  echo "ERROR: please specify the name of the portal to delete"
  usage
  exit 102
fi

if [[ $name_supplied -eq 0 && "$listportals" == "no" ]]; then
  echo "ERROR: please specify the name of the portal"
  usage
  exit 102
fi

firstchar=$(echo $portal_name |cut -c -1)
re='^[0-9]+$'
if [[ $firstchar =~ $re ]] ; then
   echo "Invalid portal Name" >&2; exit 109
fi

if [[ ${#portal_name} -lt 3 ]] ; then
   echo "Invalid portal Name" >&2; exit 109
fi


if [[ ! -e $dlcName ]]; then
  echo "DLC file doesn't exist"
exit 107
fi

file $dlcName |grep "Zip archive"
if [[ $? -eq 0 ]] ; then
 echo "Ok, DLCX is a zip file" 
else
 echo "DLCX is not a zip file, aborting..."
 exit 107
fi

LastPort=$serverport

if [[ $port_supplied -eq "0" && "$deleteportal" != "yes" && "$portalstop" != "yes"  && "$portalstart" != "yes" ]]; then
    webserverport=$(shuf -i 7000-9000 -n 1)
    port_supplied=1
    webserverport_supplied=1
    a_webserverport="$(netstat -tulpn|grep $webserverport|wc -l)"
    if [[ "$a_webserverport" != "0" ]]; then
         webserverport=$(shuf -i 7000-9000 -n 1)
    fi

fi


echo webserverport=$webserverport

username=$portal_name
sslport=$(($serverport + 1))
configfile=/home/$username/portal.conf
hostname=`hostname`
#PublicIP=`dig +short $hostname`
#PrivateIP=`hostname -I`
#PrivateIP=`echo $PrivateIP | head -n1 | awk ''{print $1;}''`

#if [[ $PublicIP = "127.0.1.1" ]]; then
#  PublicIP=$PrivateIP
#fi

if [[ "$deleteportal" != "yes"  && "$portalstop" != "yes" && "$portalstart" != "yes" ]]; then
  a_serverport="$(netstat -tulpn|grep $serverport|wc -l)"
  if [[ "$a_serverport" != "0" && "$username" != "sageteaadmin"  ]]; then
  echo "Port $serverport is in use"
  exit 103
  fi

  a_webserverport="$(netstat -tulpn|grep $webserverport|wc -l)"
  if [[ "$a_webserverport" != "0" && "$username" != "sageteaadmin" ]]; then
  echo "Port $webserverport is in use"
  exit 103
  fi

  userexist="$(compgen -u|grep -w $username|wc -l)"
  if [[ "$userexist" != "0" && "$username" != "sageteaadmin" ]]; then
  echo "User $username already exists"
  exit 104
  fi

#  pythoninstalled="$(ls -ll /usr/bin/python |wc -l)"
#  if [[ "$pythoninstalled" == "0" ]]; then
#  echo "python is not installed"
#  exit 106
#  fi


fi


if [[ ! -e $LOG ]]; then
touch $LOG
fi

echo $(date) >> $LOG 2>&1
echo echo "portal_name: $portal_name  |  password: $password | Webserverport $webserverport  | Default: $DEFAULT  |  Number_of_args: $num_of_args  | \\nDelete_Portal: $deleteportal  |  Name_Supplied: $name_supplied  |  Port_Supplied $port_supplied DLC: $dlcName |License $license "   >> $LOG 2>&1


#Delete portal

if [[ "$deleteportal" == "yes" ]]; then

  userexist="$(compgen -u|grep $username|wc -l)"
  if [[ "$userexist" == "0" ]]; then
  echo "$username does not exist"
  exit 105
  fi

  systemctl stop sageteacloudsq@$username.service
  systemctl disable sageteacloudsq@$username.service
  systemctl daemon-reload

  rm -f  /etc/systemd/system/sageteacloudsq@$username.service

if [[ $server == "s1.sageteasoftware.com" ]]; then
  rm -f /etc/apache2/sites-enabled/$username.sagetea.ai.conf
  rm -f /etc/apache2/sites-enabled/$username-ssl.sagetea.ai.conf
  rm -f /etc/apache2/sites-available/$username.sagetea.ai.conf
  rm -f /etc/apache2/sites-available/$username-ssl.sagetea.ai.conf
  service apache2 reload
elif  [[ $server == "t1.sageteasoftware.com" ]]; then
ssh -t -p 3217 backup@s1.sageteasoftware.com -i /usr/local/s1 "sudo rm -f /etc/apache2/sites-enabled/$username.sagetea.ai.conf"
ssh -t -p 3217 backup@s1.sageteasoftware.com -i /usr/local/s1 "sudo rm -f /etc/apache2/sites-enabled/$username-ssl.sageteas.ai.conf"
ssh -t -p 3217 backup@s1.sageteasoftware.com -i /usr/local/s1 "sudo rm -f /etc/apache2/sites-available/$username.sagetea.ai.conf"
ssh -t -p 3217 backup@s1.sageteasoftware.com -i /usr/local/s1 "sudo rm -f /etc/apache2/sites-available/$username-ssl.sagetea.ai.conf"
ssh -t -p 3217 backup@s1.sageteasoftware.com -i /usr/local/s1 "sudo service apache2 reload"
else
echo "Local install, skipping"
fi

  sudo -u postgres bash -c "psql -c \"DROP DATABASE $username;\""
  sudo -u postgres bash -c "psql -c \" DROP USER $username;\""

  userdel $username
  groupdel $username
  rm -rf /home/$username
  rm /etc/sudoers.d/$username
  systemctl daemon-reload

  exit 0
fi

if [[ "$portalstart" == "yes" && "$portalstop" == "yes" ]]; then
  echo "mutual exclusive parameters"
  exit 102
fi


if [[ "$portalstart" == "yes" ]]; then
  systemctl start sageteacloudsq@$username.service
  exit 0
fi

if [[ "$portalstop" == "yes" ]]; then
  systemctl stop sageteacloudsq@$username.service
  exit 0
fi



#All looks good, let''s create a portal!

systemctl daemon-reload
useradd -m $username

cd /home/$username

if [[ "$DBType" == "psql" ]]; then
sudo -u postgres bash -c "psql -c \"CREATE USER $username;\""
sudo -u postgres bash -c "psql -c \"ALTER USER $username with password 'ghQw9f_98hjm';\""
sudo -u postgres bash -c "psql -c \"ALTER USER $username with superuser;\""
sudo -u postgres bash -c "psql -c \"ALTER USER $username with createrole;\""
sudo -u postgres bash -c "psql -c \"ALTER USER $username with createdb;\""
sudo -u postgres createdb $username
sudo -u postgres bash -c "psql -c \"ALTER DATABASE $username OWNER TO $username;\""
fi

#if [ ! -f /etc/sudoers.d/$username ]; then
#adduser $username sudo
#echo "$username  ALL=NOPASSWD: ALL" > /etc/sudoers.d/$username
#fi

myProcessFileName=`basename $dlcName`
myProcessFileName="/opt/sageteacloudsq/dlcx/"$myProcessFileName

touch $configfile
echo "{" > $configfile
echo "\"userName\":\"$username\"," >> $configfile
echo "\"networkPort\":$webserverport," >> $configfile
if [[ "$DBType" == "psql" ]]; then
echo "\"databaseType\":\"postgresql\"," >> $configfile
else
echo "\"databaseType\":\"mysql\"," >> $configfile
fi

echo "\"databaseServer\":\"localhost\"," >> $configfile
echo "\"databasePort\":5432," >> $configfile
if [[ "$password_supplied" == "1" ]]; then
echo "\"initialUserPassword\":\"$password\"," >> $configfile
fi

echo "\"licenseKey\":\"$license\"," >> $configfile
echo "\"databasePassword\":\"LFMLO-F1HOE-FXCQZ-2UAKJ-YKKFJ-U\"," >> $configfile
echo "\"databaseUserName\":\"$username\"," >> $configfile
echo "\"databaseName\":\"$username\"," >> $configfile
echo "\"initialApplicationFilename\":\"$myProcessFileName\"," >> $configfile
if [[ "$demo" == "yes" ]]; then
echo "\"demoSystem\":true" >> $configfile
else
echo "\"demoSystem\":false" >> $configfile
fi
echo "}" >> $configfile

cp $configfile $configfile.backup

chown -R $username:$username /home/$username
chmod -R u=rwX,g=rwX,o=X /home/$username
chmod 600 $configfile
chmod 655 $myProcessFileName

cp /etc/systemd/system/sageteacloudsq@.service /etc/systemd/system/sageteacloudsq@$username.service

systemctl daemon-reload
systemctl enable sageteacloudsq@$username.service

systemctl restart sageteacloudsq@$username.service

if [[ $server == "s1.sageteasoftware.com" ]]; then
sudo -S reverse_proxy.sh $username $webserverport $server
service apache2 reload
elif [[ $server == "t1.sageteasoftware.com" ]]; then
ssh -t -p 3217 backup@s1.sageteasoftware.com -i /usr/local/s1 "sudo -S reverse_proxy.sh $username $webserverport $server"
else
echo "Local install, launching http only: localhost:$webserverport"
fi

exit 0
