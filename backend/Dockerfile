FROM python:3.7
RUN mkdir -p /usr/src/backend
WORKDIR /usr/src/backend
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src src

#run the application
ENV PATH /usr/local/bin:$PATH
ENV FLASK_APP=src/main.py
ENV PYTHONUNBUFFERED=1

CMD flask run --host=0.0.0.0 --port=80

# # specify the port number of the container should expose

EXPOSE 80