docker stop saturn
docker rm saturn

docker tag saturn_testing_auto saturn_production

docker run -i --restart always --net="host" -v /home/saturn/bioinformatics_bin/psipred:/home/saturn/SATurn/build/bin/deployed_bin/psipred -v /home/saturn/bioinformatics_bin/tmhmm:/home/saturn/SATurn/build/bin/deployed_bin/tmhmm -v /home/saturn/SGCOxford.json:/home/saturn/SATurn/build/services/DockerConfig.json -v /home/saturn/lib:/home/saturn/lib -v /home/saturn/databases:/home/saturn/SATurn/build/databases -v /home/saturn/bioinformatics_bin/hmmer:/home/saturn/SATurn/build/bin/deployed_bin/hmmer  --name saturn -d saturn_production
