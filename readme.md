# OPM CLI

CLI Tool for Odin package publishing

## Build

git submodule dependency to [odin-http](https://github.com/laytan/odin-http)

`git submodule update --init --recursive`

Note: odin-http only supports Linux & Mac at present. Windows users must use wsl to get libssl.a as a dep.

Build (`odin build .`) and stash in desired directory, add `opm` to your `PATH`.

NOTE: IO/stream refactor broke odin-http. curl for windows minimally copied in. not impl.

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

## Feature Todo/Wish List

- Produce docs in style of core that will be loaded to the 'signatures' tab for packages
- Getting of packages (Held for Curl+discuss structure with gb)
