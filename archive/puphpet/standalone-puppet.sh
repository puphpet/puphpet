#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

PUPHPET_CORE_DIR=/opt/puphpet

find ${PUPHPET_CORE_DIR}/shell -type f -exec chmod +x {} \;

/bin/bash ${PUPHPET_CORE_DIR}/shell/initial-setup.sh
/bin/bash ${PUPHPET_CORE_DIR}/shell/install-puppet.sh

puppet apply --verbose \
    --hiera_config ${PUPHPET_CORE_DIR}/puppet/hiera.yaml \
    --modulepath "${PUPHPET_CORE_DIR}/puppet/modules/:${PUPHPET_CORE_DIR}/puppet/manifests/:/etc/puppet/modules" \
    ${PUPHPET_CORE_DIR}/puppet/manifests/
