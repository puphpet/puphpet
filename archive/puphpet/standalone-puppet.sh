#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

PUPHPET_CORE_DIR=/opt/puphpet
PUPHPET_STATE_DIR=/opt/puphpet-state

find ${PUPHPET_CORE_DIR}/shell -type f -exec chmod +x {} \;

/bin/bash ${PUPHPET_CORE_DIR}/shell/initial-setup.sh
/bin/bash ${PUPHPET_CORE_DIR}/shell/install-puppet.sh

GEM=/opt/puppetlabs/puppet/bin/gem

GEM_PATH=$(cat "${PUPHPET_STATE_DIR}/gem_path") \
FACTER_provisioner_type='remote' \
puppet apply --verbose \
    --hiera_config ${PUPHPET_CORE_DIR}/puppet/hiera.yaml \
    --modulepath "${PUPHPET_CORE_DIR}/puppet/modules/:${PUPHPET_CORE_DIR}/puppet/manifests/:/opt/puppetlabs/puppet/modules/" \
    ${PUPHPET_CORE_DIR}/puppet/manifests/
