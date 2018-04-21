FROM continuumio/anaconda3

MAINTAINER David Damerell <david.damerell@sgc.ox.ac.uk>

RUN apt-get update && \
apt-get install -y git vim build-essential libcap2-bin libcairo2 unzip procps python-pip default-jdk
RUN useradd -ms /bin/bash saturn
RUN pip install abifpy
USER saturn
#COPY saturn.tar.gz /tmp/saturn.tar.gz
#RUN cd /home/saturn && \
#tar zxvf /tmp/saturn.tar.gz
USER saturn
RUN cd /home/saturn && \
git clone https://github.com/ddamerell53/SATurn.git
RUN cd /home/saturn/SATurn/build/bin && \
wget https://nodejs.org/dist/v8.9.3/node-v8.9.3-linux-x64.tar.xz && \
tar xvf node-v8.9.3-linux-x64.tar.xz  && \
rm -rf node && \
mv node-v8.9.3-linux-x64 node
ENV PATH="/home/saturn/SATurn/build/bin/node/bin:/opt/conda/bin/:${PATH}"
RUN cd /home/saturn/SATurn/build/bin/node && \
npm install restify@4.3.1 tempfile debug bull jsonwebtoken@7.4.1 redis fs-extra pg temp socket.io node-uuid socketio-jwt sqlite3 ncbi-eutils split http-proxy agentkeepalive nodemailer node-uuid needle
RUN cd /home/saturn/SATurn/build/bin && \
wget http://download.redis.io/releases/redis-4.0.6.tar.gz && \
tar zxvf redis-4.0.6.tar.gz && \
cd redis-4.0.6 && \
make && \
cd ../ && \
mv redis-4.0.6 redis 
RUN cd /home/saturn/SATurn/build/bin/deployed_bin && \
wget https://github.com/ddamerell53/SATurn/releases/download/v1.0-beta.6/GlycanBuilder.zip && \
unzip GlycanBuilder.zip && \
rm GlycanBuilder.zip
RUN cd /home/saturn/SATurn/build/bin/deployed_bin && \
wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.7.1+-x64-linux.tar.gz && \
tar zxvf ncbi-blast-2.7.1+-x64-linux.tar.gz && \
mv ncbi-blast-2.7.1+/bin/* . && \
rm -rf ncbi-blast-2.7.1+ && \
rm ncbi-blast-2.7.1+-x64-linux.tar.gz && \
wget http://www.clustal.org/omega/clustalo-1.2.4-Ubuntu-x86_64 && \
mv clustalo-1.2.4-Ubuntu-x86_64 clustalo && \
chmod u+x clustalo && \
wget http://www.clustal.org/download/current/clustalw-2.1-linux-x86_64-libcppstatic.tar.gz && \
tar zxvf clustalw-2.1-linux-x86_64-libcppstatic.tar.gz && \
rm clustalw-2.1-linux-x86_64-libcppstatic.tar.gz && \
cp clustalw-2.1-linux-x86_64-libcppstatic/clustalw2 clustalw2 &&\
rm -rf clustalw-2.1-linux-x86_64-libcppstatic/ 
RUN cd /home/saturn/SATurn/build && \
wget https://github.com/ddamerell53/SATurn/releases/download/v1.0-beta.6/databases.zip && \
unzip databases.zip && \
rm databases.zip
RUN cp /home/saturn/SATurn/src_python/ABIConverter.py /home/saturn/SATurn/build/bin/deployed_bin/ABIConverter && \
chmod u+x /home/saturn/SATurn/build/bin/deployed_bin/ABIConverter.py
USER root
RUN setcap 'cap_net_bind_service=+ep' /home/saturn/SATurn/build/bin/node/bin/node
#ENV JAVA_HOME=





