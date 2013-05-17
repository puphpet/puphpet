<?php

namespace Puphpet\Domain\PuppetModule;

class MySQL extends PuppetModuleAbstract implements PuppetModuleInterface
{
    protected $mysql;

    public function __construct($mysql)
    {
        $this->mysql = is_array($mysql) ? $mysql : array();
    }

    /**
     * Return ready to use MySQL array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->mysql)) {
            return array();
        }

        $this->removeIncomplete();

        return $this->mysql;
    }

    /**
     * DB arrays must contain both a user and dbname key
     *
     * @return self
     */
    protected function removeIncomplete()
    {
        if (empty($this->mysql['dbuser'])) {
            $this->mysql['dbuser'] = array();
        }

        foreach ($this->mysql['dbuser'] as $key => $db) {
            if (empty($db['user']) || empty($db['dbname'])) {
                unset($this->mysql['dbuser'][$key]);
                continue;
            }
        }

        return $this;
    }
}
