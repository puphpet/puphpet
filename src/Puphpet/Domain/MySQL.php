<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class MySQL extends Domain
{
    public function removeIncomplete($dbs)
    {
        foreach ($dbs as $key => $db) {
            if (empty($db['user']) || empty($db['dbname'])) {
                unset($dbs[$key]);
                continue;
            }
        }

        return $dbs;
    }
}
