#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

EXEC_ONCE_DIR="$1"
EXEC_ALWAYS_DIR="$2"

shopt -s nullglob
files=("${VAGRANT_CORE_FOLDER}"/files/"${EXEC_ONCE_DIR}"/*)

if [[ ! -f "/.puphpet-stuff/${EXEC_ONCE_DIR}-ran" && (${#files[@]} -gt 0) ]]; then
    echo "Running files in files/${EXEC_ONCE_DIR}"
    find "${VAGRANT_CORE_FOLDER}/files/${EXEC_ONCE_DIR}" -maxdepth 1 -not -path '*/\.*' -type f \( ! -iname "empty" \) -exec chmod +x '{}' \; -exec {} \;
    echo "Finished running files in files/${EXEC_ONCE_DIR}"
    echo "To run again, delete file /.puphpet-stuff/${EXEC_ONCE_DIR}-ran"
    touch /.puphpet-stuff/exec-once-ran
fi

echo "Running files in files/${EXEC_ALWAYS_DIR}"
find "${VAGRANT_CORE_FOLDER}/files/${EXEC_ALWAYS_DIR}" -maxdepth 1 -not -path '*/\.*' -type f \( ! -iname "empty" \) -exec chmod +x '{}' \; -exec {} \;
echo "Finished running files in files/${EXEC_ALWAYS_DIR}"
