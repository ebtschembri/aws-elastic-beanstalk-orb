if [[ $EUID == 0 ]]; then export SUDO=""; else # Check if we are root
  export SUDO="sudo";
fi

SetupPython() {
    # setups pyenv on a debian based system
    # these are the system level deps for pyevn install, these are offically recommneded for install by AWS
    $SUDO apt-get -qq update > /dev/null
    $SUDO apt-get -qq -y install build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev
    $SUDO apt-get -qq -y install python3-dev
    SetupVirtualEnv
}

SetupVirtualEnv() {
    if [ $(which pip | tail -1) ]; then
        echo "pip found"
    else
        echo "pip not found"
        $SUDO curl https://bootstrap.pypa.io/get-pip.py | python3
    fi
    pip install virtualenv
}



InstallEBCLI() {
    cd /tmp || { echo "Not able to access /tmp"; return; }
    git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git
    if uname -a | grep Darwin > /dev/null 2>&1; then
        brew install zlib openssl readline
        $SUDO CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(xcrun --show-sdk-path)/usr/include" LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix zlib)/lib" ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer >/dev/null 2>&1
        return $?
    elif uname -a | grep Linux > /dev/null 2>&1; then
        PY=
        if [ $(which python3 | tail -1) ]; then
            echo "Python3 env found"
            SetupVirtualEnv
        else
            echo "Python3 env not found, setting up python 3.7.9 with pyenv"
            SetupPython
        fi
    fi
            python3 aws-elastic-beanstalk-cli-setup/scripts/ebcli_installer.py
}

CheckAWSEnvVars() {
    ERRMSGTEXT="has not been set. This environment variable is required for authentication."
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        echo "AWS_ACCESS_KEY_ID $ERRMSGTEXT"
        exit 1
    fi
    if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "AWS_SECRET_ACCESS_KEY $ERRMSGTEXT"
        exit 1
    fi
    if [ -z "$AWS_DEFAULT_REGION" ]; then
        echo "AWS_DEFAULT_REGION $ERRMSGTEXT"
        exit 1
    fi
}

# Will not run if sourced for bats.
# View src/tests for more information.
TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    CheckAWSEnvVars
    InstallEBCLI
fi