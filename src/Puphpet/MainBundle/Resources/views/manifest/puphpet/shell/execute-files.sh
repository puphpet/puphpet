#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

EXEC_ONCE_DIR="$1"
EXEC_ALWAYS_DIR="$2"

echo "Running files in files/${EXEC_ONCE_DIR}"

if [ -d "/.puphpet-stuff/${EXEC_ONCE_DIR}-ran" ]; then
    rm -rf "/.puphpet-stuff/${EXEC_ONCE_DIR}-ran"
fi

if [ ! -f "/.puphpet-stuff/${EXEC_ONCE_DIR}-ran" ]; then
   sudo touch "/.puphpet-stuff/${EXEC_ONCE_DIR}-ran"
   echo "Created file /.puphpet-stuff/${EXEC_ONCE_DIR}-ran"
fi

find "${VAGRANT_CORE_FOLDER}/files/${EXEC_ONCE_DIR}" -maxdepth 1 -type f -name '*.sh' | sort | while read FILENAME; do
    SHA1=$(sha1sum "${FILENAME}")

    if ! grep -x -q "${SHA1}" "/.puphpet-stuff/${EXEC_ONCE_DIR}-ran"; then
        sudo /bin/bash -c "echo \"${SHA1}\" >> \"/.puphpet-stuff/${EXEC_ONCE_DIR}-ran\""

        chmod +x "${FILENAME}"
        /bin/bash "${FILENAME}"
    else
        echo "Skipping executing ${FILENAME} as contents have not changed"
    fi
done

echo "Finished running files in files/${EXEC_ONCE_DIR}"
echo "To run again, delete hashes you want rerun in /.puphpet-stuff/${EXEC_ONCE_DIR}-ran or the whole file to rerun all"

echo "Running files in files/${EXEC_ALWAYS_DIR}"

find "${VAGRANT_CORE_FOLDER}/files/${EXEC_ALWAYS_DIR}" -maxdepth 1 -type f -name '*.sh' | sort | while read FILENAME; do
    chmod +x "${FILENAME}"
    /bin/bash "${FILENAME}"
done

echo "Finished running files in files/${EXEC_ALWAYS_DIR}"
