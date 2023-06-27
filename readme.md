# OPM CLI

CLI Tool for Odin package publishing

## Build

git submodule dependencies: `git submodule update --init`

Build (`odin build .`) and stash in desired directory, add `opm` to your `PATH`.

NOTE: Windows requires using `/external/curl/libcurl-x64.dll` either copy this dll next to your executable, or download a copy from curl.se to use. Linux & Mac use the system version.

## Usage

```text
OPM Commands:
`opm publish` - publishes a package
`opm token SECRET_TOKEN` - sets environment variable for auth token
```

Storing auth token via `opm token` is Linux-Only at present. The token is stored as an environment variable `OPM_TOKEN`. This can be manually set for Windows and Darwin. (FIXME)

Note: `opm publish` performs an **upsert** on the package, but an **insert** on the version, meaning you can update package's fields with publish, but cannot edit/update the version itself.

## Fetching - Not Impl

Downloading via CLI is not planned at this time. once the web side is stabilized and the compiler component is implemented, the feature will be implemented.

## Feature Todo/Wish List

- Produce docs in style of core that will be loaded to the 'signatures' tab for packages
- Fetching of packages (Held for discuss structure with gb)
