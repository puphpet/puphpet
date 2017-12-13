#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

PUPHPET_CORE_DIR=/opt/puphpet
PUPHPET_STATE_DIR=/opt/puphpet-state

EXEC_ONCE_DIR="$1"
EXEC_ALWAYS_DIR="$2"

echo "Running files in files/${EXEC_ONCE_DIR}"

if [ -d "${PUPHPET_STATE_DIR}/${EXEC_ONCE_DIR}-ran" ]; then
    rm -rf "${PUPHPET_STATE_DIR}/${EXEC_ONCE_DIR}-ran"
fi

if [ ! -f "${PUPHPET_STATE_DIR}/${EXEC_ONCE_DIR}-ran" ]; then
   sudo touch "${PUPHPET_STATE_DIR}/${EXEC_ONCE_DIR}-ran"
   echo "Created file ${PUPHPET_STATE_DIR}/${EXEC_ONCE_DIR}-ran"
fi

find "${PUPHPET_CORE_DIR}/files/${EXEC_ONCE_DIR}" -maxdepth 1 -type f -name '*.sh' | sort | while read FILENAME; do
    SHA1=$(sha1sum "${FILENAME}")

    if ! grep -x -q "${SHA1}" "${PUPHPET_STATE_DIR}/${EXEC_ONCE_DIR}-ran"; then
        sudo /bin/bash -c "echo \"${SHA1}\" >> \"${PUPHPET_STATE_DIR}/${EXEC_ONCE_DIR}-ran\""

        chmod +x "${FILENAME}"
        /bin/bash "${FILENAME}"
    else
        echo "Skipping executing ${FILENAME} as contents have not changed"
    fi
done

echo "Finished running files in files/${EXEC_ONCE_DIR}"
echo "To run again, delete hashes you want rerun in ${PUPHPET_STATE_DIR}/${EXEC_ONCE_DIR}-ran or the whole file to rerun all"

if [ -z ${EXEC_ALWAYS_DIR} ]; then
    exit 0
fi

echo "Running files in files/${EXEC_ALWAYS_DIR}"

find "${PUPHPET_CORE_DIR}/files/${EXEC_ALWAYS_DIR}" -maxdepth 1 -type f -name '*.sh' | sort | while read FILENAME; do
    chmod +x "${FILENAME}"
    /bin/bash "${FILENAME}"
done

echo "Finished running files in files/${EXEC_ALWAYS_DIR}"
