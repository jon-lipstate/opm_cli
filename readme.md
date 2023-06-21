# OPM CLI

CLI Tool for Odin package publishing

## Build

git submodule dependency to [odin-http](https://github.com/laytan/odin-http)

`git submodule update --init`

Build (`odin build .`) and stash in desired directory, add `opm` to your `PATH`.

## Usage

```text
OPM Commands:
`opm publish` - publishes a package
`opm token SECRET_TOKEN` - sets environment variable for auth token
```

Storing auth token via `opm token` is Linux-Only at present. The token is stored as an environment variable `OPM_TOKEN`. This can be manually set for Windows and Darwin. (FIXME)

Note: `opm publish` performs an upsert on the package, but an insert on the version, meaning you can update package's fields with publish, but cannot edit/update the version itself.

## Fetching - Not Impl

Downloading via CLI is not planned at this time. once the web side is stabilized, the feature will be implemented.
