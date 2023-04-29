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
# The next lines install the postgresql requirements and then removes the dependencies only needed for install
# to keep the docker file as small as possible
#  apk add --update --no-cache postgresql-client && \
# the vitual flag puts those packages in a .tmp file so we can remove it easier at the bottom
  #    apk add --update --no-cache --virtual .tmp-build-dev \
  #      build-base postgresql-dev musl-dev && \

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
      build-base postgresql-dev musl-dev  zlib zlib-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps &&  \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

# This updates enviroment varible in image. Defines the directory for executibles.
ENV PATH="/py/bin:$PATH"

# specifies the user that we switch to from root
USER django-user