<?php

use Symfony\Component\HttpKernel\Kernel;
use Symfony\Component\Config\Loader\LoaderInterface;
use Symfony\Component\Yaml\Yaml;

class AppKernel extends Kernel
{
    static $cacheDir;
    static $logDir;

    public function registerBundles()
    {
        $bundles = array(
            new Symfony\Bundle\FrameworkBundle\FrameworkBundle(),
            new Symfony\Bundle\SecurityBundle\SecurityBundle(),
            new Symfony\Bundle\TwigBundle\TwigBundle(),
            new Symfony\Bundle\AsseticBundle\AsseticBundle(),
            new Symfony\Bundle\MonologBundle\MonologBundle(),
            new Sensio\Bundle\FrameworkExtraBundle\SensioFrameworkExtraBundle(),
            new Cocur\Slugify\Bridge\Symfony\CocurSlugifyBundle(),
            new Puphpet\MainBundle\PuphpetMainBundle(),
        );

        if (in_array($this->getEnvironment(), array('dev', 'test'), true)) {
            $bundles[] = new Symfony\Bundle\DebugBundle\DebugBundle();
            $bundles[] = new Symfony\Bundle\WebProfilerBundle\WebProfilerBundle();
            $bundles[] = new Sensio\Bundle\DistributionBundle\SensioDistributionBundle();
            $bundles[] = new Sensio\Bundle\GeneratorBundle\SensioGeneratorBundle();
        }

        return $bundles;
    }

    public function registerContainerConfiguration(LoaderInterface $loader)
    {
        $loader->load($this->getRootDir().'/config/config_'.$this->getEnvironment().'.yml');
    }

    public function getCacheDir()
    {
        if (static::$cacheDir) {
            return static::$cacheDir;
        }

        $yaml = new Yaml();

        $env = $this->getEnvironment();

        $parameters = $yaml::parse(file_get_contents(__DIR__ . '/config/parameters.yml'));
        $config     = $yaml::parse(file_get_contents(__DIR__ . "/config/config_{$env}.yml"));

        if (!empty($parameters['parameters']['cache_dir'])) {
            static::$cacheDir = $parameters['parameters']['cache_dir'];
        } elseif (!empty($config['parameters']['cache_dir'])) {
            static::$cacheDir = $config['parameters']['cache_dir'];
        } else {
            static::$cacheDir = parent::getCacheDir();
        }

        if (!is_dir(static::$cacheDir)) {
            @mkdir(static::$cacheDir, 0774, true);
            @chgrp(static::$cacheDir, 'www-data');
        }

        return static::$cacheDir;
    }

    public function getLogDir()
    {
        if (static::$logDir) {
            return static::$logDir;
        }

        $yaml = new Yaml();

        $env = $this->getEnvironment();

        $parameters = $yaml::parse(file_get_contents(__DIR__ . '/config/parameters.yml'));
        $config     = $yaml::parse(file_get_contents(__DIR__ . "/config/config_{$env}.yml"));

        if (!empty($parameters['parameters']['log_dir'])) {
            static::$logDir = $parameters['parameters']['log_dir'];
        } elseif (!empty($config['parameters']['log_dir'])) {
            static::$logDir = $config['parameters']['log_dir'];
        } else {
            static::$logDir = parent::getLogDir();
        }

        if (!is_dir(static::$logDir)) {
            @mkdir(static::$logDir, 0777, true);
            @chgrp(static::$logDir, 'www-data');
        }

        return static::$logDir;
    }
}
