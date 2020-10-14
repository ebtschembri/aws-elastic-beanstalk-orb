if [[ $EUID == 0 ]]; then export SUDO=""; else # Check if we are root
  export SUDO="sudo";
fi

InstallEBCLI() {
    cd /tmp || { echo "Not able to access /tmp"; return; }

    if uname -a | grep Darwin > /dev/null 2>&1; then
        oit clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git
        brew install zlib openssl readline
        $SUDO CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(xcrun --show-sdk-path)/usr/include" LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix zlib)/lib" ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer >/dev/null 2>&1
        return $?
    elif uname -a | grep Linux > /dev/null 2>&1; then
        $SUDO apt-get -qq update > /dev/null
        $SUDO apt-get -qq -y install build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev
        pip install pipx
        pipx install awsebcli
    fi
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