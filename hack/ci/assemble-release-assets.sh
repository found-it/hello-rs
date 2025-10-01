#!/bin/sh
set -e

checksum_sha256() {
  if type sha256sum >/dev/null 2>&1; then
    sha256sum "${1}"
  else
    shasum -a 256 "${1}"
  fi
}

asset() {
  cp "${1}" "${2}"
  PREVIOUS="${PWD}"
  cd "$(dirname "${2}")"
  BASE_FILE_NAME="$(basename "${2}")"
  checksum_sha256 "${BASE_FILE_NAME}" >"${BASE_FILE_NAME}.sha256"
  cd "${PREVIOUS}"
}

FORM="${1}"
shift
TAG_NAME="${1}"
shift
PLATFORM="${1}"
shift

mkdir -p target/assets

for SOURCE_FILE_PATH in "${@}"; do
  if [ "${FORM}" = "hello" ]; then
    SUFFIX=""
    if echo "${PLATFORM}" | grep "^windows-" >/dev/null; then
      SUFFIX=".exe"
    fi

    # For backwards-compatibility
    # Strip off the binary name down to the directory.
    directory="${SOURCE_FILE_PATH%/"$FORM""$SUFFIX"}"

    # Expand wildcard path
    artifact_path=$(find "${directory}" -name "${FORM}${SUFFIX}" -type f)
    echo "Found: ${artifact_path}"

    asset "${artifact_path}" "target/assets/hello_${TAG_NAME}_${PLATFORM}${SUFFIX}"
  else
    echo "ERROR: Unknown form '${FORM}'"
    exit 1
  fi
done
