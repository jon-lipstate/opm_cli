# OPM CLI

CLI Tool for Odin-Package Submittals

## Build

git submodule dependency to [odin-http](https://github.com/laytan/odin-http)

`git submodule update --init`

## Usage

`opm` alone prints the command options:

```text
OPM Commands:
`opm publish` - publishes a package
`opm update` - update current version of a package (TODO / NOT-IMPL)
`opm token SECRET_TOKEN` - sets environment variable for auth token
```

Storing auth token (Linux-Only at present):

```text
opm token SECRET_TOKEN
```

Note: the Auth token is stored as an environment variable `OPM_TOKEN`. This can be manually set for Windows and Darwin. (FIXME)

Upload new Package/Version:

```text
opm publish
```

Note: at present, `opm publish` performs an upsert, meaning you can update packages with the same command. It may be split into an insert and update if requested. I could forsee accidental version overwrites. (FIXME)
