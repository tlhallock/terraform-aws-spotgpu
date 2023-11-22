
sudo apt update
sudo apt upgrade -y
sudo apt install ncdu
#sudo snap install helix

cd /home/ubuntu
rm *

sudo mkfs.xfs /dev/xvdh
sudo mkdir /work
sudo mount -o rw /dev/xvdh /work
sudo chown ubuntu -R /work
sudo echo "UUID=$(lsblk -nr -o UUID,MOUNTPOINT | grep "/work" | cut -d ' ' -f 1) /work xfs defaults,nofail 1 2" >> /etc/fstab
cd /work


# Installs anaconda, not needed with current ami
# mkdir -p /work/Applications/anaconda
# cd /work/Applications/anaconda

#wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
#mv Anaconda3-2023.09-0-Linux-x86_64.sh conda-installer.sh
#chmod a+x conda-installer.sh
#./conda-installer.sh -u -b -p ./anaconda3
#echo 'export PATH="/work/Applications/anaconda/anaconda3/bin:$PATH"' >> /home/ec2-user/.bashrc
#rm conda-installer.sh

# conda act
# conda install -c conda-forge jupyterhub jupyterlab  

# download cuda / conda ...
# start jupyter hub
# install helix, zellij

