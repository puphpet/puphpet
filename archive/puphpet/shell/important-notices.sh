#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

PUPHPET_CORE_DIR=/opt/puphpet
PUPHPET_STATE_DIR=/opt/puphpet-state

if [[ -f "${PUPHPET_STATE_DIR}/displayed-important-notices" ]]; then
    exit 0
fi

cat "${PUPHPET_CORE_DIR}/shell/ascii-art/important-notices.txt"
touch "${PUPHPET_STATE_DIR}/displayed-important-notices"
