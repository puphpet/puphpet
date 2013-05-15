<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class Server extends Domain
{
    /**
     * @param string $aliases Submitted .bash_aliases contents
     * @return string
     */
    public function formatBashAliases($aliases)
    {
        return trim(str_replace("\r\n", "\n", $aliases));
    }

    /**
     * @param string $packages A comma-delimited string of package names
     * @return array
     */
    public function formatPackages($packages)
    {
        $packages = !empty($packages) ? explode(',', $packages) : [];

        $key = array_search('python-software-properties', $packages);

        // python-software-properties is installed by default, remove to prevent duplicate Puppet function
        if ($key !== FALSE) {
            unset($packages[$key]);
        }

        return $this->quoteArray($packages);
    }
}
