<?php

namespace Puphpet\Domain\Compiler\Manifest;

use Puphpet\Domain;
use Puphpet\Domain\Compiler\FormatterInterface;

/**
 * Formats all puppet module configuration in this way the Compiler
 * and thus the twig template could use them.
 */
class Formatter implements FormatterInterface
{
    private $puppetModules = array();
    private $database;
    private $webserver;
    private $webserverConfiguration;
    private $serverConfiguration;
    private $projectConfiguration;
    private $phpConfiguration;
    private $databaseConfiguration;
    private $formattedConfiguration = array();

    /**
     * Constructor
     *
     * @param array  $puppetModules
     * @param string $defaultWebserver
     */
    public function __construct($puppetModules = array(), $defaultWebserver = 'apache')
    {
        $this->puppetModules = $puppetModules;
        $this->webserver = $defaultWebserver;
    }

    /**
     * @param null|array $configuration
     */
    public function setServerConfiguration($configuration)
    {
        $this->serverConfiguration = $configuration;
    }

    /**
     * @param null|array $configuration
     */
    public function setProjectConfiguration($configuration)
    {
        $this->projectConfiguration = $configuration;
    }

    /**
     * @param null|array $configuration
     */
    public function setDatabaseConfiguration($database, $configuration)
    {
        $this->database = $database;
        $this->databaseConfiguration = $configuration;
    }

    /**
     * @param null|array $configuration
     */
    public function setPhpConfiguration($configuration)
    {
        $this->phpConfiguration = $configuration;
    }

    /**
     * @param string     $webserver
     * @param null|array $configuration
     */
    public function setWebserverConfiguration($webserver, $configuration)
    {
        $this->webserver = $webserver;
        $this->webserverConfiguration = $configuration;
    }

    /**
     * @return array
     */
    public function format()
    {
        $this->formatPuppetModule('project', $this->projectConfiguration);
        $this->formatPuppetModule('server', $this->serverConfiguration);
        $this->formatWebserverConfiguration();
        $this->formatDatabaseConfiguration();
        $this->formatPhpConfiguration();

        return $this->formattedConfiguration;
    }

    protected function formatWebserverConfiguration()
    {
        $this->addConfiguration('webserver', $this->webserver);
        $this->addConfiguration('php_service', $this->webserver == 'nginx' ? 'php5-fpm' : 'apache');

        $method = 'format' . ucfirst($this->webserver) . 'Configuration';
        $this->$method();
    }

    protected function formatApacheConfiguration()
    {
        $this->formatPuppetModule('apache', $this->webserverConfiguration);
    }

    protected function formatNginxConfiguration()
    {
        $this->formatPuppetModule('nginx', $this->webserverConfiguration);
    }

    protected function formatDatabaseConfiguration()
    {
        $this->addConfiguration('database', $this->database);

        // database is optional
        if (!$this->database) {
            return;
        }

        $method = 'format' . ucfirst($this->database) . 'Configuration';
        $this->$method();
    }

    protected function formatMysqlConfiguration()
    {
        $this->formatPuppetModule('mysql', $this->databaseConfiguration);
    }

    protected function formatPostgresqlConfiguration()
    {
        $this->formatPuppetModule('postgresql', $this->databaseConfiguration);
    }

    protected function formatPhpConfiguration()
    {
        $php = $this->getPuppetModule('php');
        $php->setConfiguration($this->phpConfiguration);

        if (!empty($this->databaseConfiguration['root'])) {
            if ('mysql' == $this->database) {
                $php->addPhpModule('php5-mysql', true);
            } elseif ('postgresql' == $this->database) {
                $php->addPhpModule('php5-pgsql', true);
            }
        }

        $this->addConfiguration('php', $php->getFormatted());
    }

    /**
     * @param string     $moduleName
     * @param null|array $configuration
     */
    protected function formatPuppetModule($moduleName, $configuration)
    {
        $puppetModule = $this->getPuppetModule($moduleName);
        $puppetModule->setConfiguration($configuration);

        $this->addConfiguration($moduleName, $puppetModule->getFormatted());
    }

    /**
     * @param string $moduleName
     *
     * @return \Puphpet\Domain\PuppetModule\PuppetModuleAbstract
     * @throws \InvalidArgumentException                         when given module name is not registered
     */
    protected function getPuppetModule($moduleName)
    {
        if (!array_key_exists($moduleName, $this->puppetModules)) {
            $msg = sprintf('PuppetModule not registered for configuration "%s"', $moduleName);
            throw new \InvalidArgumentException($msg);
        }

        return $this->puppetModules[$moduleName];
    }

    protected function addConfiguration($type, $configuration)
    {
        $this->formattedConfiguration[$type] = $configuration;
    }
}
