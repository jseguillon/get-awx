FROM alpine as template-get

#TODO : build-arg version
RUN wget https://github.com/ansible/awx/archive/9.0.1.tar.gz -O /root/awx.tar.gz
RUN cd /root  && mkdir awx && ls  -al && tar -xzvf awx.tar.gz -C /root/awx --strip-components 1

FROM python:3.5.9-alpine
COPY --from=template-get /root/awx/installer/roles/local_docker/templates/ /templates/

COPY requirements.txt /requirements.txt
RUN pip install -r requirements.txt

COPY generate.py /generate.py

CMD [ "/usr/local/bin/python3", "/generate.py" ]
