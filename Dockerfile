
FROM alpine as template-get

# Get release from github
#TODO : build-arg version
RUN wget https://github.com/ansible/awx/archive/9.0.1.tar.gz -O /root/awx.tar.gz
RUN cd /root  && mkdir awx && ls  -al && tar -xzvf awx.tar.gz -C /root/awx --strip-components 1

# Main image
FROM python:3.5.9-alpine

COPY requirements.txt /requirements.txt
RUN pip install -r requirements.txt

RUN mkdir /awx/
COPY --from=template-get /root/awx/installer/roles/local_docker/templates/ /awx/templates/
COPY generate.py /generate.py
COPY default.values.yml.j2 /awx/config/default.values.yml.j2

CMD [ "/usr/local/bin/python3", "/generate.py" ]
