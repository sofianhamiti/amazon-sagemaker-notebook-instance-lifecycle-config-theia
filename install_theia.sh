set -e

sudo -u ec2-user -i <<'EOP'

#####################################
## INSTALL THEIA IDE FROM SOURCE
#####################################
CONFIG_DIR=${HOME}/lifecycle-config/config
EC2_HOME=/home/ec2-user
mkdir ${EC2_HOME}/theia && cd ${EC2_HOME}/theia

# Install nvm with node and npm.
curl https://raw.githubusercontent.com/creationix/nvm/v0.37.2/install.sh | bash

source ${EC2_HOME}/.nvm/nvm.sh
nvm install 12
nvm use 12
npm install -g yarn

NODE_OPTIONS=--max_old_space_size=4096
cp ${CONFIG_DIR}/package.json ${EC2_HOME}/theia/
nohup yarn &

#####################################
### CONFIGURE THEIA IDE
#####################################
THEIA_PATH=$PATH
mkdir ${EC2_HOME}/.theia
cp ${CONFIG_DIR}/launch.json ${EC2_HOME}/.theia/
cp ${CONFIG_DIR}/settings.json ${EC2_HOME}/.theia/

#####################################
### INTEGRATE THEIA IDE WITH JUPYTER PROXY
#####################################
cat >>/home/ec2-user/.jupyter/jupyter_notebook_config.py <<EOC
c.ServerProxy.servers = {
  'theia': {
    'command': ['yarn', '--cwd', '/home/ec2-user/theia', 'start', '/home/ec2-user/SageMaker', '--port', '{port}'],
    'environment': {'PATH': '${THEIA_PATH}'},
    'absolute_url': False,
    'timeout': 30
  }
}
EOC

source /home/ec2-user/anaconda3/bin/activate JupyterSystemEnv
pip install jupyter-server-proxy pylint autopep8 yapf pyflakes pycodestyle 'python-language-server[all]'
jupyter labextension install @jupyterlab/server-proxy
conda deactivate
EOP