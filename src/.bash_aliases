function login {
    echo "---------------------------------------------------------"
    echo " Login "
    echo "---------------------------------------------------------"
    echo " Running aws_okta_keyman "
    echo " "
    # $1 = org, $2 = user name
    if [[ -z $1 || -z $2 ]];
    then
        echo "Usage: login ORG USERNAME"
    else
        aws_okta_keyman --org $1 --username $2
    fi
}

function test {
    echo "---------------------------------------------------------"
    echo " Test "
    echo "---------------------------------------------------------"
    echo " This executes a simple AWS command, for test purposes."
    echo " "
    aws sts get-caller-identity
}

function creds {
    echo "---------------------------------------------------------"
    echo " Credentials "
    echo "---------------------------------------------------------"
    echo " For more details: cat ~/.aws/credentials "
    echo " "
    cat ~/.aws/credentials | grep aws_access_key_id && cat ~/.aws/credentials | grep aws_secret_access_key
}

function usage {
    echo "---------------------------------------------------------"
    echo " Usage (${OKTA_ORG:-"<undefined>"}/${OKTA_USER:-"<undefined>"}) "
    echo "---------------------------------------------------------"
    echo " Command Aliases: "
    echo "     usage - this help screen "
    echo "     login - login to aws "
    echo "         Usage: login ORG USERNAME "
    echo "     test - test aws connectivity "
    echo "     creds - show your temporary access key and secret "
    echo " Installed CLI: "
    echo "     aws - aws-cli v2 "
    echo " "
}

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/.local/bin" ]];
then
    PATH="$HOME/.local/bin:$PATH"
fi

if [[ -z $OKTA_USER ]];
then
    OKTA_USER=`whoami`
fi

# if mode is HOST, then LOGIN and exit.
if [[ $MODE == 'HOST' ]];
then
    # make sure required env variables are set
    if [[ -z $OKTA_ORG || -z $OKTA_USER ]];
    then
        echo "ERROR: OKTA_ORG and OKTA_USER environment variables must be set."
        exit 1
    fi
    
    # login
    aws_okta_keyman -o $OKTA_ORG -u $OKTA_USER
    result=$?

    # if login failed... sad face.
    if [ $result -eq 0 ];
    then
        echo "Login Success."
        echo "Credentials have been copied to the host."
        exit 0;
    else
        echo "Login failed."
        exit $result
    fi
fi;

# if mode is REFRESH, then LOGIN with --reup option.
if [[ $MODE == 'REFRESH' ]];
then
    # make sure required env variables are set
    if [[ -z $OKTA_ORG || -z $OKTA_USER ]];
    then
        echo "ERROR: OKTA_ORG and OKTA_USER environment variables must be set."
        exit 1
    fi
    
    # login
    aws_okta_keyman -o $OKTA_ORG -u $OKTA_USER --reup
    result=$?

    # if login failed... sad face.
    if [ $result -eq 0 ];
    then
        exit 0;
    else
        echo "Authentication failed."
        exit $result
    fi
fi;

# if the cred env variables are set then login.
# otherwise, skip it.
if [[ ${SKIP_AUTH:-"false"} == "false" && -n $OKTA_ORG ]];
then
    aws_okta_keyman -o $OKTA_ORG -u $OKTA_USER
fi

usage