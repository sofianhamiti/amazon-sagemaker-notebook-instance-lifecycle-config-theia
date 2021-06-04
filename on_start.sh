set -e

sudo -u ec2-user -i <<'EOP'
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