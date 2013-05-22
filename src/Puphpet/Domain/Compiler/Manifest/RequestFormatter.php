<?php

namespace Puphpet\Domain\Compiler\Manifest;

use Puphpet\Domain\Compiler\FormatterInterface;
use Symfony\Component\HttpFoundation\Request;

/**
 * Proxy for the real formatter
 */
class RequestFormatter implements FormatterInterface
{
    /**
     * @var Formatter
     */
    private $formatter;

    /**
     * @var Request
     */
    private $request;

    private $webserver = null;

    /**
     * @param Formatter $formatter
     */
    public function __construct(Formatter $formatter)
    {
        $this->formatter = $formatter;
    }

    /**
     * @param Request $request
     */
    public function bindRequest(Request $request)
    {
        $this->request = $request;
    }

    /**
     * Builds and returns formatted configuration
     * which could be used within templates
     *
     * @return string
     */
    public function format()
    {
        if (!$this->request) {
            throw new \InvalidArgumentException('You have to bind an request instance before formatting');
        }

        $this->formatter->setServerConfiguration($this->get('server'));
        $this->formatter->setMysqlConfiguration($this->get('mysql'));
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
     */
    private function get($key)
    {
        return $this->request->request->get($key);
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
}
