<?php

namespace Puphpet\Domain\Compiler;

/**
 * Container of the file contents during Compilation.
 */
class Compilation
{

    private $content;
    private $configuration;
    private $separator;

    /**
     * @param string $content
     * @param array  $configuration
     * @param string $separator
     */
    public function __construct($content, $configuration = array(), $separator = PHP_EOL)
    {
        $this->content = $content;
        $this->configuration = $configuration;
        $this->separator = $separator;
    }

    /**
     * @return string
     */
    public function getContent()
    {
        return $this->content;
    }

    /**
     * @param string $additionalContent
     */
    public function addContent($additionalContent)
    {
        $this->content .= $this->separator . $additionalContent;
    }

    /**
     * @return array
     */
    public function getConfiguration()
    {
        return $this->configuration;
    }
}
