echo "$(date) Launching post-install script" >> /tmp/sagetea 2>&1
sleep 15

#Elasticsearch & Kibana
#if [ ! -e /etc/apt/sources.list.d/elastic-7.x.list ]; then
#  cd /tmp
#  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - 
#  echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list 
#  echo "Installing Elasticsearch and Kibana" >> /tmp/sagetea 2>&1
#  echo $(date) >> /tmp/sagetea 2>&1
#  apt-get update  >> /tmp/sagetea 2>&1
#  apt-get install -y kibana elasticsearch  >> /tmp/sagetea 2>&1
#  systemctl restart sageteacloudsq@sdefault.service
#fi

#Bazel
#if [ ! -e /etc/apt/sources.list.d/bazel.list ]; then
#  echo "Installing Bazel" >> /tmp/sagetea 2>&1
#  pip install -U --user pip numpy wheel
#  pip install -U --user keras_preprocessing --no-deps
#  cd /tmp
#  curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
#  sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
#  echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
#  echo $(date) >> /tmp/sagetea 2>&1
#  apt-get update  >> /tmp/sagetea 2>&1
#  apt-get install -y bazel >> /tmp/sagetea 2>&1
#  git clone https://github.com/tensorflow/tensorflow.git >> /tmp/sagetea 2>&1
#  cd tensorflow >> /tmp/sagetea 2>&1
#  ./configure >> /tmp/sagetea 2>&1
# fi

#Hishams code
# cd /usr/bin/sageteacloudsq/marchnet/git/marchnetwork
# sudo add-apt-repository ppa:deadsnakes/ppa
# sudo apt-get install python3.8 python3.8-dev python3.8-distutils python3.8-venv
# /usr/bin/python3.8 -m venv venv
# source venv/bin/activate
# pip3 install pandas flask matplotlib numpy 
# python3 flaskApp.py

  systemctl restart sageteacloudsq@sdefault.service

