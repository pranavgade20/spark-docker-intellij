FROM bde2020/spark-python-template:3.2.0-hadoop3.2
	  
COPY py/wordcount.py /app/

ENV SPARK_APPLICATION_PYTHON_LOCATION /app/wordcount.py
ENV SPARK_APPLICATION_ARGS "/spark/README.md"

# ssh server and essentials
RUN apk add --update --no-cache openssh sudo
# stuff required to install/build packages like numpy/pandas
# RUN apk add make automake gcc g++ subversion python3-dev

# setting up ssh server - i dunno which parts are necessary, but this seems to work after a lot of pain
RUN mkdir -p /var/run/sshd \
  && touch /root/.Xauthority \
  && true
RUN printf 'PasswordAuthentication no \nPermitRootLogin without-password \nPubkeyAuthentication yes \nStrictModes no' >> /etc/ssh/sshd_config

# create server keys, you might need to remove previous keys from ~/.ssh/known_kosts on the client
RUN ssh-keygen -A
# adding my publickey to the server
RUN mkdir /root/.ssh && echo "YOUR_KEY_HERE" > /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys
# alpine ssh doesn't work unless root has a password??
RUN echo 'root:dummy_passwd'|chpasswd
# expose ssh port 
EXPOSE 22
# run ssh server
CMD /usr/sbin/sshd -D
