Refer to [NVM's documentation](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-nvm-on-alpine-linux) for important compatibility details regarding which NodeJS versions are supported on which each version of Alpine Linux.

If you wish to install a version of NodeJS after the alpine-nvm feature has been installed you can do so by running `nvm install <version>`. It will attempt to download [pre-built unofficial binaries](https://github.com/nodejs/unofficial-builds) offered by the NodeJS project.

Alternatively, you can build that same version of NodeJS from source by running `NVM_NODEJS_ORG_MIRROR= nvm install -s <version>`.
