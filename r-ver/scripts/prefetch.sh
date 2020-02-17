#!/bin/sh

curl -sLO https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start.sh
curl -sLO https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start-notebook.sh
curl -sLO https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start-singleuser.sh
chmod +x *.sh
