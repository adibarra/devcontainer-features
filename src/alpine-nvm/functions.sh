#!/bin/sh

set -e

# Function to get the latest NVM version
fetch_latest_nvm_version() {
    echo "$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | awk -F'"' '/tag_name/{print $4}' | cut -c 2-)"
}

# Function to adjust NVM_VERSION if required
adjust_nvm_version() {
    case "$1" in
        latest) echo "$(fetch_latest_nvm_version)" ;;
        *) echo "$1" ;;
    esac
}

# Function to adjust NODE_VERSION if required
adjust_node_version() {
    case "$1" in
        none) echo "" ;;
        lts) echo "lts/*" ;;
        latest) echo "node" ;;
        *) echo "$1" ;;
    esac
}

# Function to ensure that login shells get the correct path if the user updated the PATH using ENV
update_path() {
    rm -f /etc/profile.d/00-restore-env.sh
    echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
    chmod +x /etc/profile.d/00-restore-env.sh
}

# Function to update the rc files
update_rc() {
    local _rc_content="$1"
    local _profiles="/etc/profile /etc/bash/bashrc /etc/zsh/zshrc"
    touch "/etc/profile"

    echo "Updating rc files: ${_profiles}"
    for _profile in $_profiles; do
        if [ -f "${_profile}" ] && [[ "$(cat ${_profile})" != *"${_rc_content}"* ]]; then
            echo -e "${_rc_content}" >> "${_profile}"
        fi
    done
}

# Function to determine the appropriate non-root user
determine_user() {
    local _username="${1:-"${_REMOTE_USER:-"automatic"}"}"

    if [ "${_username}" = "auto" ] || [ "${_username}" = "automatic" ]; then
        local _current_user=$(getent passwd 1000 | cut -d: -f1)
        local _possible_users="vscode node codespace '${_current_user}'"

        for _user in "${_possible_users}"; do
            if getent passwd "${_user}" > /dev/null 2>&1; then
                echo "${_user}"
                return
            fi
        done
        echo "root"
    elif [ "${_username}" = "none" ] || ! getent passwd "${_username}" > /dev/null 2>&1; then
        echo "root"
    else
        echo "${_username}"
    fi
}

# Function to add a user to a specified group, creating the group if it doesn't exist
add_user_to_group() {
    local _username=$1
    local _groupname=$2

    # Check if the group exists, create it if it doesn't
    if ! getent group "${_groupname}" > /dev/null 2>&1; then
        echo "Creating group '${_groupname}'..."
        addgroup -S "${_groupname}"
    fi

    # Add the user to the group
    echo "Adding user '${_username}' to group '${_groupname}'..."
    adduser "${_username}" "${_groupname}"
}

