# Install official Python image
FROM python:3.12.2-slim

# Avoid Python to write .pyc files on the import of source modules
ENV PYTHONDONTWRITEBYTECODE 1
# Force the stdout and stderr streams to be unbuffered. 
ENV PYTHONUNBUFFERED 1

ENV APP=/app

# Define working directory
WORKDIR $APP

RUN apt-get update && apt-get install -y netcat-traditional

# Copy config file and dependencies
COPY requirements.txt $APP

# Install poetry and dependencies
RUN pip3 install --upgrade pip 
RUN pip3 install -r requirements.txt --no-cache-dir

# Copy entrypoint.sh to / 
COPY ./docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY . $APP

ENTRYPOINT [ "/entrypoint.sh" ]