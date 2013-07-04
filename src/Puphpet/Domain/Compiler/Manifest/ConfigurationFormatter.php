<?php

namespace Puphpet\Domain\Compiler\Manifest;

use Puphpet\Domain\Compiler\FormatterInterface;
use Puphpet\Domain\Configuration\Configuration;

/**
 * Proxy for the real formatter.
 * Receives complete configuration and triggers formatting
 * of according modules.
 */
class ConfigurationFormatter implements FormatterInterface
{
    /**
     * @var Formatter
     */
    private $formatter;

    /**
     * @var Configuration
     */
    private $configuration;

    private $webserver = null;
    private $database = null;

    /**
     * @param Formatter $formatter
     */
    public function __construct(Formatter $formatter)
    {
        $this->formatter = $formatter;
    }

    public function bindConfiguration(Configuration $configuration)
    {
        $this->configuration = $configuration;
    }

    /**
     * Builds and returns formatted configuration
     * which could be used within templates
     *
     * @return array
     */
    public function format()
    {
        if (!$this->configuration) {
            throw new \InvalidArgumentException('You have to bind an request instance before formatting');
        }

        $this->formatter->setServerConfiguration($this->get('server'));
        $this->formatter->setProjectConfiguration($this->get('project', array()));

        if ($this->getDatabase()) {
            if ('mysql' == $this->getDatabase()) {
                $this->formatter->setDatabaseConfiguration('mysql', $this->get('mysql'));
            } else {
                $this->formatter->setDatabaseConfiguration('postgresql', $this->get('postgresql'));
            }
        }

        $this->formatter->setPhpConfiguration($this->get('php'));

        if ('nginx' == $this->getWebserver()) {
            $this->formatter->setWebserverConfiguration('nginx', $this->get('nginx'));
        } else {
            $this->formatter->setWebserverConfiguration('apache', $this->get('apache'));
        }

        return $this->formatter->format();
    }

    /**
     * Fetches something from request
     *
     * @param  string      $key
     * @param  string|null $default
     */
    private function get($key, $default = null)
    {
        return $this->configuration->get($key, $default);
    }

    protected function getWebserver()
    {
        if (null === $this->webserver) {
            $webserver = $this->get('webserver', 'apache');

            // quick validate webserver
            $this->webserver = in_array($webserver, ['apache', 'nginx']) ? $webserver : 'apache';
        }

        return $this->webserver;
    }

    /**
     * Tells which database server has been chosen
     *
     * @return string Database name
     */
    protected function getDatabase()
    {
        if (null === $this->database) {
            $this->database = $this->get('database', false);

            if ($this->database) {
                // quick validation of database value
                $this->database = in_array($this->database, ['mysql', 'postgresql']) ? $this->database : 'mysql';
            }
        }

        return $this->database;
    }
}
