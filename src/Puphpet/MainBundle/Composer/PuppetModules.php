<?php

namespace Puphpet\MainBundle\Composer;

use Composer\Script\Event;

abstract class PuppetModules
{
    static public function downloadPuppetDependencies(Event $event)
    {
        $vendorDir = realpath($event->getComposer()->getConfig()->get('vendor-dir'));
        $rootDir   = realpath($vendorDir . '/../');

        echo 'Running librarian-puppet';

        $cwd = getcwd();
        chdir($rootDir);
        exec('librarian-puppet install --clean 2>&1');
        chdir($cwd);
    }
}
