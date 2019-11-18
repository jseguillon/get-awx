#!/usr/bin/env python


import os, yaml, json, shlex
import logging
logging.basicConfig(level=logging.DEBUG)

from jinja2 import Environment, FileSystemLoader

# Mimic Ansible addionak Jinja filter
def quote(input):
    logging.debug("Quoting : %s", input)
    return shlex.quote(str(input))

# Prepare Jinja env
env = Environment(loader = FileSystemLoader("./"), trim_blocks=True, lstrip_blocks=True)
env.filters['quote'] = quote # Reigster quote filer
 

logging.info("Generating values")

# Load config values
config_src = yaml.safe_load(open("config/values.yml"))
# Config file itself is a template => render it 
template = env.get_template("config/values.yml")
data = template.render(config_src)
logging.debug(data)
config_src = yaml.safe_load(data)



templates = os.listdir(os.path.join(os.path.dirname(__file__),'templates'))

# TODO change for Docker target dir 
os.makedirs(os.path.expanduser(config_src['docker_compose_dir']), exist_ok=True )
for templateName in templates: 
    logging.info("Generating from : %s", templateName)

    template = env.get_template("templates/" + templateName)
    data = template.render(config_src)
    logging.debug(data)
    
    # TODO change for Docker target dir plus alternative dest for docker-compose
    target=os.path.expanduser(os.path.join(config_src['docker_compose_dir'] ,os.path.splitext(templateName)[0]))
    logging.info("Dumping to : %s " + target)
    
    f = open(target, "w")
    f.write(data)
    f.close()

logging.info("Create secret key file")
# TODO Docker dir
f = open(os.path.expanduser(os.path.join(config_src['docker_compose_dir'] , "SECRET_KEY")), "w")
f.write(config_src['secret_key'])
f.close()
logging.info("Done")
