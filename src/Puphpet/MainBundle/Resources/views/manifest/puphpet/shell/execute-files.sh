#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

shopt -s nullglob
files=("${VAGRANT_CORE_FOLDER}"/files/exec-once/*)

if [[ (${#files[@]} -gt 0) ]]; then
    echo 'Running files in files/exec-once'
    if [ ! -d '/.puphpet-stuff/exec-once-ran' ]; then 
       mkdir '/.puphpet-stuff/exec-once-ran'
       echo 'Created directory /.puphpet-stuff/exec-once-ran'
    fi
    find "${VAGRANT_CORE_FOLDER}/files/exec-once" -maxdepth 1 -not -path '*/\.*' -type f \( ! -iname "empty" \) -exec cp -n '{}' /.puphpet-stuff/exec-once-ran \;
    find /.puphpet-stuff/exec-once-ran -maxdepth 1 -type f -exec chmod +x '{}' \; -exec {} \; -exec sh -c '>{}' \;
    echo 'Finished running files in files/exec-once'
    echo 'To run again, delete file(s) you want rerun in /.puphpet-stuff/exec-once-ran or the whole folder to rerun all'
fi

echo 'Running files in files/exec-always'
find "${VAGRANT_CORE_FOLDER}/files/exec-always" -maxdepth 1 -not -path '*/\.*' -type f \( ! -iname "empty" \) -exec chmod +x '{}' \; -exec {} \;
echo 'Finished running files in files/exec-always'
