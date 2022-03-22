FROM python:3

ARG USER
ARG ORG
RUN : "${USER:?User argument needs to be set and non-empty.}"

WORKDIR /root

# install aws-cli
ARG TARGETARCH
RUN echo ${TARGETARCH}
RUN apt-get update && apt-get install -yy less && \
    [ $TARGETARCH = "arm" ] && \
    curl https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscli.zip || \
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscli.zip
RUN unzip awscli.zip && \
    ./aws/install && \
    rm -rf aws && \
    rm awscli.zip

# create new user
RUN useradd -ms /bin/bash ${USER} && \
    mkdir /home/${USER}/.aws && \
    chown ${USER} /home/${USER}/.aws
USER ${USER}
WORKDIR /home/${USER}
VOLUME [ "/home/${USER}/.aws" ]

# install aws_okta_keyman
RUN pip install aws_okta_keyman

# install alias
COPY src/.bash_aliases .

ENV MODE=INTERACTIVE
ENV OKTA_ORG=${ORG}

CMD [ "bash" ]