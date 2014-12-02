<?php

namespace Puphpet\MainBundle\Composer;

use Composer\Script\Event;

abstract class PuppetModules
{
    static public function downloadPuppetDependencies(Event $event)
    {
        $vendorDir = realpath($event->getComposer()->getConfig()->get('vendor-dir'));
        $puppetDir = realpath($vendorDir . '/../archive/puphpet/puppet');

        echo 'Running librarian-puppet';

        $cwd = getcwd();
        chdir($puppetDir);
        exec('librarian-puppet install --clean 2>&1');
        exec('rm -rf .librarian .tmp');
        chdir($cwd);
    }
}
