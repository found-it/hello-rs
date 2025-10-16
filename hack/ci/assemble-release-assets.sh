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
  previous="${PWD}"
  cd "$(dirname "${2}")"
  base_file_name="$(basename "${2}")"
  checksum_sha256 "${base_file_name}" >"${base_file_name}.sha256"
  cd "${previous}"
}

if [ -z "${EDERA_ASSEMBLE_FORM}" ]; then
  echo "EDERA_ASSEMBLE_FORM env is missing"
  exit 1
fi

if [ -z "${EDERA_ASSEMBLE_TAG_NAME}" ]; then
  echo "EDERA_ASSEMBLE_TAG_NAME env is missing"
  exit 1
fi

if [ -z "${EDERA_ASSEMBLE_PLATFORM}" ]; then
  echo "EDERA_ASSEMBLE_PLATFORM env is missing"
  exit 1
fi

if [ -z "${EDERA_ASSEMBLE_RELEASE_DIR}" ]; then
  echo "EDERA_ASSEMBLE_RELEASE_DIR env is missing"
  exit 1
fi

FORM="${EDERA_ASSEMBLE_FORM}"
TAG_NAME="${EDERA_ASSEMBLE_TAG_NAME}"
PLATFORM="${EDERA_ASSEMBLE_PLATFORM}"

env | grep EDERA

mkdir -p target/assets

for SOURCE_FILE_PATH in ${EDERA_ASSEMBLE_RELEASE_DIR}; do
  echo "handling $SOURCE_FILE_PATH"
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
