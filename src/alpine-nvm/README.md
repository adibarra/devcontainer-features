
# alpine-nvm (alpine-nvm)

Installs Node Version Manager (NVM) on Alpine Linux

## Example Usage

```json
"features": {
    "ghcr.io/adibarra/devcontainer-features/alpine-nvm:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| nodeBuildDependencies | Install build dependencies for Node.js | boolean | false |
| nodeBuildSource | Build Node.js from source if nodeVersion is not 'none' | boolean | false |
| nodeVersion | Node.js version to pre-install: 'lts', 'latest', 'none', or a specific version | string | none |
| nvmInstallPath | Path to install NVM | string | /usr/local/share/nvm |
| nvmVersion | NVM version to install: exact version or 'latest' | string | latest |

Refer to [NVM's documentation](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-nvm-on-alpine-linux) for important compatibility details regarding which NodeJS versions are supported on which each version of Alpine Linux.

If you wish to install a version of NodeJS after the alpine-nvm feature has been installed you can do so by running `nvm install <version>`. It will attempt to download [pre-built unofficial binaries](https://github.com/nodejs/unofficial-builds) offered by the NodeJS project.

Alternatively, you can build that same version of NodeJS from source by running `NVM_NODEJS_ORG_MIRROR= nvm install -s <version>`.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/adibarra/devcontainer-features/blob/main/src/alpine-nvm/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
