#!/bin/sh
set -e

retry() {
  for i in $(seq 1 10); do
    if "${@}"; then
      return 0
    else
      sleep "${i}"
    fi
  done
  "${@}"
}

if [ -z ${HELLO_ASSET_TAG} ]; then
  echo "TAG env is missing"
  exit 1
fi

cd target/assets

retry gh release upload "${HELLO_ASSET_TAG}" --clobber ./*
