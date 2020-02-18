FROM python:3

WORKDIR /script

ADD init.py requirements.txt ./

RUN pip3 install --no-cache-dir -r requirements.txt

CMD ["python", "./init.py"]