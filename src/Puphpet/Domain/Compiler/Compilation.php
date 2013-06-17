<?php

namespace Puphpet\Domain\Compiler;

class Compilation {

    private $content;
    private $separator;

    public function __construct($content = null, $separator = PHP_EOL)
    {
        $this->content = $content;
        $this->separator = $separator;
    }

    public function getContent()
    {
        return $this->content;
    }

    public function addContent($additionalContent)
    {
        $this->content .= $this->separator . $additionalContent;
    }
}
