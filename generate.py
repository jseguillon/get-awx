#!/usr/bin/env python

import os, yaml, json, shlex, datetime
import logging
logging.basicConfig(level=logging.DEBUG)

from jinja2 import Environment, FileSystemLoader
from datetime import datetime
from shutil import copyfile

# Mimic Ansible addionak Jinja filter
def quote(input):
    logging.debug("Quoting : %s", input)
    return shlex.quote(str(input))

# Prepare Jinja envs
env = Environment(loader = FileSystemLoader("/awx"), trim_blocks=True, lstrip_blocks=True)
env.filters['quote'] = quote # Reigster quote filer

# put local config to root Jinja
copyfile("/opt/local/config/values.yml", "/awx/config/values.yml")

logging.info("Generating values")

# Load default config values
default_config_src = yaml.safe_load(open("/awx/config/default.values.yml.j2"))

# Config file itself is a template => render it
template = env.get_template("config/default.values.yml.j2")
data = template.render(default_config_src)
logging.debug("default values render : ")
logging.debug(data)
default_config_src = yaml.safe_load(data)

# Load config values
config_src = yaml.safe_load(open("/awx/config/values.yml"))

# Config file itself may be a template => render it
template = env.get_template("config/values.yml")
data = template.render(config_src)
logging.debug("values render : ")
logging.debug(data)
config_src = yaml.safe_load(data)

# Merge config and defaults
config_src = {**default_config_src, **config_src}
logging.debug(config_src)

# list templates
source_template_dir='/awx/templates'
templates = os.listdir(source_template_dir)
logging.debug(templates)

# Create target dir then iterate
os.makedirs(config_src['docker_compose_dir'], exist_ok=True)
for templateName in templates:
    logging.info("Generating from : %s", templateName)

    template = env.get_template("templates/" + templateName)
    data = template.render(config_src)
    logging.debug(data)

    # Render template
    target=os.path.join(config_src['docker_compose_dir'],os.path.splitext(templateName)[0])
    logging.info("Dumping to : %s ", config_src['docker_compose_dir'])

    f = open(target, "w")
    f.write(data)
    f.close()

logging.info("Create secret key file")

# Dump static secret key
f = open(os.path.join(config_src['docker_compose_dir'], "SECRET_KEY"), "w")
f.write(config_src['secret_key'])
f.close()
