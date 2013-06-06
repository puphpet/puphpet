<?php

namespace Puphpet\Domain\File;

use Puphpet\Domain\Compiler\Manifest\RequestFormatter;
use Symfony\Component\HttpFoundation\Request;

/**
 * Generator for domain file archive from given request
 */
class RequestGenerator
{

    /**
     * @var Generator
     */
    private $generator;

    /**
     * @var RequestFormatter
     */
    private $requestFormatter;

    /**
     * @param Generator $generator
     * @param RequestFormatter $requestFormatter
     */
    public function __construct(Generator $generator, RequestFormatter $requestFormatter)
    {
        $this->generator = $generator;
        $this->requestFormatter = $requestFormatter;
    }

    /**
     * Extracts and formats request params and converts a domain file from it
     *
     * @param Request $request
     *
     * @return \Puphpet\Domain\File
     */
    public function generateArchive(Request $request)
    {
        // extracting box configuration
        $box = $request->request->get('box');
        $boxConfiguration = ['box' => $box];

        // extracting manifest configuration
        $this->requestFormatter->bindRequest($request);
        $manifestConfiguration = $this->requestFormatter->format();

        // building vagrant configuration
        $vagrantConfiguration = array_merge(
            $boxConfiguration,
            ['mysql' => $manifestConfiguration['mysql']]
        );

        return $this->generator->generateArchive(
            $boxConfiguration,
            $manifestConfiguration,
            $vagrantConfiguration
        );
    }
}