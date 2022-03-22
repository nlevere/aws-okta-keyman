# AWS Okta Keymanager

- [Introduction](#introduction)
- [Build](#build)
  - [Using Docker CLI](#docker-cli)
  - [Using VSCode](#vscode)
- [Usage](#usage)
  - [Interaction mode](#interactive-mode)
  - [Host mode](#host-mode)
  - [Refresh mode](#refresh-mode)

## Introduction

This container uses code based on `allard_aws_okta_keyman` from Jay Allard and `aws_okta_keyman` from Nathan V. This code wraps `aws_okta_keyman` in an easy to use docker image eliminating the need to install dependencys locally and simplifies authenticating with AWS using Okta.

- AWS Okta KeyMan Login: [allard_aws_okta_keyman](https://github.com/jayallard/allard_aws_okta_keyman)
- AWS Okta Keyman: [aws_okta_keyman](https://github.com/nathan-v/aws_okta_keyman)
  - License: https://github.com/nathan-v/aws_okta_keyman/blob/master/LICENSE.txt

## Build

It is recommended that you build this image to customize it for your username. This is not required, but will simplify using the image.

This docker image exposes 2 build arguments that can customize the image for your targeted environment and username.

- USER (manditory) - The username for the image. Ideally this name would be your username, but can be anything
- ORG - The Okta organization
  - If ORG and OKTA_ORG are not set, auto authentication with not work
- TARGETARCH - The target architecture of the image
  - amd64 (default) - Support for amd64 and x86_64 based images
  - arm - Support for running images nativly on Apple M1 silicon

### Docker CLI

To build the image for amd64 use the following command:
```
$ docker build --build-arg USER=${USER} --build-arg ORG=MyOrg -t aws-okta-keyman .
```
This will build the image using the current logged on user and install the `x86_64` version of the AWS CLI

To build the image for Apple M1 silicon use the following command:
```
$ docker build --build-arg USER=${USER} --build-arg ORG=MyOrg --build-arg TARGETARCH=arm -t aws-okta-keyman .
```
This will build the image using the current logged on user and install the `aarch64` version of the AWS CLI

### VSCode

To build images in VSCode, add a new docker-build task to tasks.json.
```
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build Docker Image",
            "type": "docker-build",
            "dockerBuild": {
                "context": "${workspaceFolder}",
                "buildArgs": {
                    "ORG": "${config:okta.organization}",
                    "USER": "${config:okta.username}",
                    "TARGETARCH": "arm"
                },
                "tag": "${config:okta.username}/aws-okta-keyman"
            }
        }
    ]
}
```
Add the following settings to the users settings.json:
```
{
    "okta.organization": "trimble",
    "okta.username": "${USER}"
}
```
## Usage

There are three modes that this image support:

- INTERACTIVE - In this mode, the docker image will provide a terminal with AWS CLI installed and ready to use
- HOST - In this mode, the docker image will authenticate you with AWS using Okta, copy credentials locally, and then exit
- REFRESH - In this mode, the docker image will autheticate you with AWS using Okta and copy credentials locally. Once an hour, this credentials will be refreshed

### Interactive mode

USE CASE: You need to use AWS CLI.

This will:

- Create a container
- Authenticate you with AWS using Okta if credentials are provided
- Provide a bash terminal with AWS CLI installed

Optional settings:

- OKTA_ORG - Override the defaut organization
  - If not provided, this defaults to the value set when the image was built
- OKTA_USER - Override the defaut username
  - If not provided, this defaults to user defined when image was built
- SKIP_AUTH - Skip authenticating when running image
  - false (default)
- -v - Copy the AWS credentials file to a local folder
  - If provided, the AWS credentials can be used on the host

If image was built using the correct Okta username, then the following command will provide a bash terminal with AWS CLI installed:
```
$ docker run -it aws-okta-keyman
```
Full command with all optional settings:
```
$ docker run -it -e OKTA_ORG=MyOrg -e OKTA_USER=${USER} -v ~/.aws:/home/${USER}/.aws aws-okta-keyman
```
NOTE: The `${USER}` in the `-v` argument must match the USER build argument when the image was built.

To run image with out logging in, use the following command:
```
$ docker run -it -e SKIP_AUTH=true aws-okta-keyman
$ login <organization> <username>
```
Replace `<organization>` and `<username>` with your own credentials.

### Host mode

USE CASE: You want to use AWS CLI on your host environment.

This will:

- Create a container
- Authenticate you with AWS using Okta if credentials are provided
- Copy credentials to the host
- Exit container

Required settings:
- MODE - Override the default operating mode
  - Set to HOST
- -v - Copy the AWS credentials file to a local folder
  - If provided, the AWS credentials can be used on the host 

Optional settings:

- OKTA_ORG - Override the defaut organization
  - If not provided, this defaults to the value set when the image was built
- OKTA_USER - Override the defaut username
  - If not provided, this defaults to user defined when image was built

If image was built using the correct Okta username, then the following command will provide a bash terminal with AWS CLI installed:
```
$ docker run -it -e MODE=HOST -v ~/.aws:/home/${USER}/.aws aws-okta-keyman
```
Full command with all optional settings:
```
$ docker run -it -e OKTA_ORG=MyOrg -e OKTA_USER=${USER} -e MODE=HOST -v ~/.aws:/home/${USER}/.aws aws-okta-keyman
```
NOTE: The `${USER}` in the `-v` argument must match the USER build argument when the image was built.

### Refresh mode

USE CASE: You want to use AWS CLI on your host environment beyond the default session length of 1 hour.

This will:

- Create a container
- Authenticate you with AWS using Okta if credentials are provided
- Copy credentials to the host
- Refresh credentials every 50 minutes

Required settings:
- MODE - Override the default operating mode
  - Set to REFRESH
- -v - Copy the AWS credentials file to a local folder
  - If provided, the AWS credentials can be used on the host 

Optional settings:

- OKTA_ORG - Override the defaut organization
  - If not provided, this defaults to the value set when the image was built
- OKTA_USER - Override the defaut username
  - If not provided, this defaults to user defined when image was built

If image was built using the correct Okta username, then the following command will provide a bash terminal with AWS CLI installed:
```
$ docker run -it -e MODE=REFRESH -v ~/.aws:/home/${USER}/.aws aws-okta-keyman
```
Full command with all optional settings:
```
$ docker run -it -e OKTA_ORG=MyOrg -e OKTA_USER=${USER} -e MODE=REFRESH -v ~/.aws:/home/${USER}/.aws aws-okta-keyman
```
NOTE: The `${USER}` in the `-v` argument must match the USER build argument when the image was built.