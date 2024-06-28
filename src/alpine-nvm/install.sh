#!/bin/sh

# Source functions
. ./functions.sh

set -e
echo "Activating feature 'alpine-nvm'"

# Feature options
export NODE_VERSION=$(adjust_node_version "${NODEVERSION:-"lts"}")
export NVM_VERSION=$(adjust_nvm_version "${NVMVERSION:-"latest"}")
export NVM_DIR="${NVMINSTALLPATH:-"/usr/local/share/nvm"}"
export NVM_SYMLINK_CURRENT=true
NODE_BUILD_DEPENDENCIES="${NODEBUILDDEPENDENCIES:-false}"
NODE_BUILD_SOURCE="${NODEBUILDSOURCE:-false}"
USERNAME=$(determine_user)

# Dependencies
# https://github.com/nodejs/docker-node/blob/a090a371cd07499b50c077335d2f004083a55ae4/Dockerfile-alpine.template
NODE_BUILD_DEPS="binutils-gold g++ gcc gnupg libgcc linux-headers make python3"
NODE_DEPS="libstdc++"
NVM_DEPS="coreutils curl bash git"

# echo "NODE_VERSION=${NODE_VERSION}"
# echo "NVM_VERSION=${NVM_VERSION}"
# echo "NVM_DIR=${NVM_DIR}"
# echo "NVM_SYMLINK_CURRENT=${NVM_SYMLINK_CURRENT}"
# echo "NODE_BUILD_DEPENDENCIES=${NODE_BUILD_DEPENDENCIES}"
# echo "NODE_BUILD_SOURCE=${NODE_BUILD_SOURCE}"
# echo "USERNAME=${USERNAME}"

# Make sure the PATH is correct if the user updated it using ENV
update_path

# Install dependencies
echo "Installing nvm and Node dependencies..."
apk --no-cache add ${NVM_DEPS} ${NODE_DEPS}

# Install build dependencies
if [ "${NODE_BUILD_SOURCE}" = "true" ] || [ "${NODE_BUILD_DEPENDENCIES}" = "true" ]; then
    echo "Installing Node build dependencies..."
    apk --no-cache add ${NODE_BUILD_DEPS}
fi

# Define the install snippet
install_snippet="$(cat << EOF
set -e
umask 0002
export NODE_VERSION=""
export PROFILE="/dev/null"
curl -so- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash >/dev/null 2>&1
EOF
)"

# Define the content to add to the rc files
rc_content="$(cat << EOF
export NVM_DIR="${NVM_DIR}"
export NVM_IOJS_ORG_MIRROR="https://example.com"
export NVM_NODEJS_ORG_MIRROR="https://unofficial-builds.nodejs.org/download/release"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"
[ -n "\$BASH" ] && [ -s "\$NVM_DIR/bash_completion" ] && . "\$NVM_DIR/bash_completion"
EOF
)"

# Install selected nvm version
umask 0002
if [ ! -d "${NVM_DIR}" ]; then
    echo "Installing nvm..."
    add_user_to_group "${USERNAME}" nvm
    mkdir -p "${NVM_DIR}"
    chown "${USERNAME}:nvm" "${NVM_DIR}"
    chmod g+rws "${NVM_DIR}"
    su "${USERNAME}" -c "${install_snippet}" 2>&1
    update_rc "${rc_content}"
else
    echo "nvm already installed."
fi

# Install selected Node version
if [ "${NODE_VERSION}" != "" ]; then
    if [ "${NODE_BUILD_SOURCE}" = "true" ]; then
        echo "Building Node ${NODE_VERSION} from source..."
        su "${USERNAME}" -c "umask 0002 && ${rc_content} && NVM_NODEJS_ORG_MIRROR= nvm install -s '${NODE_VERSION}' && nvm alias default '${NODE_VERSION}'"
        if [ "${NODE_BUILD_DEPENDENCIES}" != "true" ]; then
            echo "Removing build dependencies..."
            apk del ${NODE_BUILD_DEPS}
        fi
    else
        echo "Downloading Node ${NODE_VERSION} from Nodejs Unofficial Builds..."
        su "${USERNAME}" -c "umask 0002 && ${rc_content} && nvm install '${NODE_VERSION}' && nvm alias default '${NODE_VERSION}'"
    fi
fi

# Clean up
echo "Cleaning up..."
rm -rf /var/cache/apk/*
su "${USERNAME}" -c "umask 0002 && ${rc_content} && nvm clear-cache"

# Ensure privs are correct for installed node versions.
echo "Setting permissions..."
mkdir -p "${NVM_DIR}/versions"
chmod -R g+rw "${NVM_DIR}/versions"

echo "Done!"
