#!/usr/bin/env python

import os, yaml, json, shlex, datetime
import logging
logging.basicConfig(level=logging.DEBUG)

from jinja2 import Environment, FileSystemLoader
from datetime import datetime
from shutil import copytree

# Mimic Ansible addionak Jinja filter
def quote(input):
    logging.debug("Quoting : %s", input)
    return shlex.quote(str(input))

# Prepare Jinja envs
env = Environment(loader = FileSystemLoader("/awx"), trim_blocks=True, lstrip_blocks=True)
env.filters['quote'] = quote # Reigster quote filer

# put local config to root Jinja
copytree("/opt/local/config/", "/awx/config/")

logging.info("Generating values")

# Load config values
config_src = yaml.safe_load(open("/awx/config/values.yml"))

# Force target value from Env var for render in docker-compose
config_src['target_dir'] = os.environ['LOCAL_DEST_DIR']

# Config file itself is a template => render it
template = env.get_template("config/values.yml")
data = template.render(config_src)
logging.debug(data)
config_src = yaml.safe_load(data)

# Source
source_template_dir='/awx/templates'

# Dest
#dir_timestamp=datetime.today().strftime('%Y-%m-%d-%H:%M:%S')
#target_env_name="awx-env" #+dir_timestamp
target_dir="/opt/local/.awx/"

templates = os.listdir(source_template_dir)

logging.debug(templates)

# Create target dir then iterate
os.makedirs(target_dir, exist_ok=True)
for templateName in templates:
    logging.info("Generating from : %s", templateName)

    template = env.get_template("templates/" + templateName)
    data = template.render(config_src)
    logging.debug(data)

    # Render template
    target=os.path.join(target_dir,os.path.splitext(templateName)[0])
    logging.info("Dumping to : %s ", target)

    f = open(target, "w")
    f.write(data)
    f.close()

logging.info("Create secret key file")

# Dump static secret key
f = open(os.path.join(target_dir, "SECRET_KEY"), "w")
f.write(config_src['secret_key'])
f.close()
