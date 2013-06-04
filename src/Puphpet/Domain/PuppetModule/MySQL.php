<?php

namespace Puphpet\Domain\PuppetModule;

class MySQL extends PuppetModuleAbstract implements PuppetModuleInterface
{
    /**
     * Return ready to use MySQL array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->configuration)) {
            return array();
        }

        if (!array_key_exists('phpmyadmin', $this->configuration)) {
            $this->configuration['phpmyadmin'] = false;
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
