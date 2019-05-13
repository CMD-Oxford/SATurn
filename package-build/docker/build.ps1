cd ubuntu_standard

docker pull continuumio/anaconda3
docker build --no-cache -t saturn .

docker tag saturn sgcit/saturn:latest

docker push sgcit/saturn:latest

docker build --no-cache -t saturn_auto -f Dockerfile_AutoStartSATurn .

docker tag saturn_auto sgcit/saturn:latest_auto

docker push sgcit/saturn:latest_auto

#sudo mount -t devpts devpts droot/dev/pts
#sudo mount -t proc proc droot/proc
#sudo mount -t sysfs sysfs droot/sys
#
#sudo mknod droot/dev/null c 1 3
#sudo mknod droot/dev/random c 1 8
#sudo chmod 666 droot/dev/{null,random}
#sudo chroot droot "/bin/bash" "/home/saturn/SATurn/build/rundebugsaturn.sh"
