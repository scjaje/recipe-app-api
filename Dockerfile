FROM python:3.9-alpine3.13
# The name or company that maintains this app
LABEL maintainer="scottH"

# Prints python logs to screen
ENV PYTHONUNBUFFERED 1

# This copys the requirements from local to that /tmp
COPY ./requirements.txt /tmp/requirements.txt
# This copies the dev to the /tmp
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# Copies the app directory
COPY ./app /app
# Sets the working directory (default)
WORKDIR /app
# opens the port 8000 too access the docker
EXPOSE 8000

# Sets default value to False so we can override it when using the docker-compose
ARG DEV=false
# Runs a command on the alpine
# && lets you break up many commands into one
# first line makes a new virutal enviroment
# second line specifies the full path and then upgrades pip
# third line installs requirements file
# fourth line removes the /tmp which removes extra dependancies to keep as lightweight as possible
# fifth line adds a new user inside the docker. Recommended to not use root. If not made, only root is there.

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# This updates enviroment varible in image. Defines the directory for executibles.
ENV PATH="/py/bin:$PATH"

# specifies the user that we switch to from root
USER django-user