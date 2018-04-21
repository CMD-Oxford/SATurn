docker run -i -p 127.0.0.1:80:80 -p 127.0.0.1:443:443 -p 127.0.0.1:8888:8888 --name chemireg --link chemireg_postgres -d chemireg
docker exec -i -t chemireg /bin/bash
