cd ubuntu_standard

docker pull continuumio/anaconda3
docker build --no-cache -t saturn .

docker tag saturn sgcit/saturn:latest

docker push sgcit/saturn:latest

docker build --no-cache -t saturn_auto -f Dockerfile_AutoStartSATurn .

docker tag saturn_auto sgcit/saturn:latest_auto

docker push sgcit/saturn:latest_auto

