set -e

sudo -u ec2-user -i <<'EOP'
#####################################
## INSTALL THEIA IDE FROM SOURCE
#####################################
EC2_HOME=/home/ec2-user
mkdir ${EC2_HOME}/theia && cd ${EC2_HOME}/theia

# Install nvm with node and npm.
curl https://raw.githubusercontent.com/creationix/nvm/v0.37.2/install.sh | bash

source ${EC2_HOME}/.nvm/nvm.sh
nvm install 12
nvm use 12
npm install -g yarn

NODE_OPTIONS=--max_old_space_size=4096
curl https://raw.githubusercontent.com/SofianHamiti/amazon-sagemaker-notebook-instance-lifecycle-config-theia/main/config/package.json -o ${EC2_HOME}/theia/package.json
nohup yarn &

#####################################
### CONFIGURE THEIA IDE
#####################################
THEIA_PATH=$PATH
mkdir ${EC2_HOME}/.theia
curl https://raw.githubusercontent.com/SofianHamiti/amazon-sagemaker-notebook-instance-lifecycle-config-theia/main/config/launch.json -o ${EC2_HOME}/.theia/launch.json
curl https://raw.githubusercontent.com/SofianHamiti/amazon-sagemaker-notebook-instance-lifecycle-config-theia/main/config/settings.json -o ${EC2_HOME}/.theia/settings.json

#####################################
### INTEGRATE THEIA IDE WITH JUPYTER
#####################################
## CONFIGURE JUPYTER PROXY TO MAP TO THE THEIA IDE
JUPYTER_ENV=/home/ec2-user/anaconda3/envs/JupyterSystemEnv
source /home/ec2-user/anaconda3/bin/activate JupyterSystemEnv
cat >>${JUPYTER_ENV}/etc/jupyter/jupyter_notebook_config.py <<EOC
c.ServerProxy.servers = {
  'theia': {
    'command': ['yarn', '--cwd', '/home/ec2-user/theia', 'start', '/home/ec2-user/SageMaker', '--port', '{port}'],
    'environment': {'PATH': '${THEIA_PATH}'},
    'absolute_url': False,
    'timeout': 30
  }
}
EOC

pip install jupyter-server-proxy pylint autopep8 yapf pyflakes pycodestyle 'python-language-server[all]'
jupyter serverextension enable --py --sys-prefix jupyter_server_proxy
jupyter labextension install @jupyterlab/server-proxy
conda deactivate
EOP

## RESTART THE JUPYTER SERVER
initctl restart jupyter-server --no-wait