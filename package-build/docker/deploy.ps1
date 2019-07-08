docker run -i --restart always -p 127.0.0.1:8091:8091 --name saturn -d saturn
docker exec -i -t saturn /bin/bash


export PATH=/opt/conda/bin:$PATH
pip install git+https://github.com/ddamerell53/socketIO-client-2.0.3.git
pip install ijson
