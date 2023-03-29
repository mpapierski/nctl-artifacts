nctl-artifacts
===

How to use this repository:

# Set up dependencies first

```
brew install sccache
```

1. ./build.sh -- it will create ./artifacts directory where nctl cache will be created.
2. cd artifacts
3. python -m http.server

Before running nctl tests you need to override remote URL

```sh
export NCTL_REMOTE_BASE_URL="http://127.0.0.1:8000"
```

# How does it work

`build.sh` iterates over supported versions, cds into specific casper-node directory, and builds a release binary. After all the artifacts are built, then it will download rest of the files from S3 bucket.

# Notes for macOS

You want to use GNU coreutils, and newer bash (5.x or later).

```sh
brew install coreutils bash
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
```
