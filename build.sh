#!/bin/bash

set -e

BASE_URL="http://nctl.casperlabs.io.s3-website.us-east-2.amazonaws.com"

REMOTE_FILES=(
    "add_bid.wasm"
    "casper-node"
    "global-state-update-gen"
    "chainspec.toml.in"
    "config.toml"
    "delegate.wasm"
    "transfer_to_account_u512.wasm"
    "undelegate.wasm"
    "withdraw_bid.wasm"
)

VERSIONS=(
    "v1.4.14"
    "v1.4.5"
    "v1.3.0"
)

export RUSTC_WRAPPER=$(which sccache)

export ARTIFACTS_DIR="$(git rev-parse --show-toplevel)/artifacts"
mkdir -p $ARTIFACTS_DIR

# Build casper-node artifacts

for VERSION in "${VERSIONS[@]}";
do
    mkdir -p ${ARTIFACTS_DIR}/${VERSION}
    pushd $VERSION
    cargo build --release -p casper-node
    cargo build --release -p global-state-update-gen
    cp ./target/release/casper-node ${ARTIFACTS_DIR}/${VERSION}/
    cp ./target/release/global-state-update-gen ${ARTIFACTS_DIR}/${VERSION}/
    popd
done

# Get rest of data from the remote

for REMOTE_FILE in "${REMOTE_FILES[@]}";
do
    for VERSION in "${VERSIONS[@]}";
    do
        if [ "$REMOTE_FILE" = 'casper-node' ];
        then
            CASPER_NODE="${ARTIFACTS_DIR}/${VERSION}/casper-node"
            echo "$VERSION: Copying compiled artifact from $CASPER_NODE..."

            if [ -f "$CASPER_NODE" ]; then
                $CASPER_NODE --version
            else
                echo "$VERSION: casper-node binary was not properly built"
                exit 1
            fi
        elif [ "$REMOTE_FILE" = 'global-state-update-gen' ];
        then
            GLOBAL_STATE_UPDATE_GEN="${ARTIFACTS_DIR}/${VERSION}/global-state-update-gen"
            echo "$VERSION: Copying compiled artifact from $GLOBAL_STATE_UPDATE_GEN..."

            if [ -f "$GLOBAL_STATE_UPDATE_GEN" ]; then
                $GLOBAL_STATE_UPDATE_GEN --version
            else
                echo "$VERSION: casper-node binary was not properly built"
                exit 1
            fi

        else
            URL="${BASE_URL}/${VERSION}/${REMOTE_FILE}"
            mkdir -p $ARTIFACTS_DIR/${VERSION}
            wget --quiet $URL -O $ARTIFACTS_DIR/${VERSION}/${REMOTE_FILE}
        fi
    done
done

# Verify

for VERSION in "${VERSIONS[@]}";
do
    CASPER_NODE="${ARTIFACTS_DIR}/${VERSION}/casper-node"
    $CASPER_NODE --version
done
