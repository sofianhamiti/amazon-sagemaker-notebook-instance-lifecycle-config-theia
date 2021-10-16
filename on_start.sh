set -e

sudo -u ec2-user -i <<'EOP'
#####################################
## INSTALL LIBSECRET DEPENDENCY
#####################################
# https://github.com/eclipse-theia/theia/pull/9807
yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/libsecret-0.18.6-1.el7.x86_64.rpm

#####################################
## INSTALL THEIA IDE
#####################################
cd ${HOME}

git clone https://github.com/SofianHamiti/amazon-sagemaker-notebook-instance-lifecycle-config-theia.git lifecycle-config

cd lifecycle-config
sh install_theia.sh

EOP

## RESTART THE JUPYTER SERVER
initctl restart jupyter-server --no-wait