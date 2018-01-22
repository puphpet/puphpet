#!/bin/bash

set -e

__DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BASE_DIR="${__DIR__}/../archive/puphpet/puppet"
CWD=`pwd`

cd `realpath ${BASE_DIR}`

librarian-puppet install --verbose
rm -rf .librarian
rm -rf .tmp

cd ${CWD}
