cp saturn_linux_x86_64_free_ubuntu_1404 build/Dockerfile
cp ../base-packages/packages/linux_x86_64.tar.gz build/
cp entrypoint.sh build/
cp startsaturn.sh build/
cd build/
sudo docker build -t=saturn/linux_x86_64_free_ubuntu_1404 .
cd ../
sudo docker save saturn/linux_x86_64_free_ubuntu_1404 | gzip > linux_x86_64_free_ubuntu_1404.tar.gz

rm -rf build/*
cp ../base-packages/packages/linux_x86_64.tar.gz build/
cp entrypoint.sh build/
cp startsaturn.sh build/
cp saturn_linux_x86_64_free_centos_7 build/Dockerfile
cd build/
sudo docker build -t=saturn/linux_x86_64_free_centos_7 .
cd ../
sudo docker save saturn/linux_x86_64_free_centos_7 | gzip > linux_x86_64_free_centos_7.tar.gz
