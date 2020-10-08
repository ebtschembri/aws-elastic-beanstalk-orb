
InstallEBCLI() {
    cd /tmp || { echo "Not able to access /tmp"; return; }
    git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git

    if uname -a | grep Darwin > /dev/null 2>&1; then
        brew install zlib openssl readline
        CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(xcrun --show-sdk-path)/usr/include" LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix zlib)/lib" ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer
        return $?
    elif uname -a | grep Linux > /dev/null 2>&1; then
        apt-get -qq update > /dev/null
        apt-get -qq -y install build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev
        ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer
    fi

    echo 'export PATH="~/.ebcli-virtual-env/executables:$PATH"'  >> "$BASH_ENV"
    . "$BASH_ENV"
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