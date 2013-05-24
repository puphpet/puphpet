<?php

namespace Puphpet\Domain\PuppetModule;

class PostgreSQL extends PuppetModuleAbstract implements PuppetModuleInterface
{
    /**
     * Return ready to use PostgreSQL array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->configuration)) {
            return array();
        }

        $this->removeIncomplete();

        return $this->configuration;
    }

    /**
     * DB arrays must contain both a user and dbname key
     *
     * @return self
     */
    protected function removeIncomplete()
    {
        if (empty($this->configuration['dbuser'])) {
            $this->configuration['dbuser'] = array();
        }

        foreach ($this->configuration['dbuser'] as $key => $db) {
            if (empty($db['user']) || empty($db['dbname'])) {
                unset($this->configuration['dbuser'][$key]);
                continue;
            }
        }

        return $this;
    }
}
