<?php

namespace Puphpet\Tests\Domain\File;

use Puphpet\Domain\File\Generator;

class GeneratorTest extends \PHPUnit_Framework_TestCase
{
    public function testGenerateArchive()
    {
        $boxConfiguration = ['box' => ['name' => 'baz']];
        $bashaliases = 'bash...';

        $vagrantConfiguration = ['vagrant' => 'foo'];
        $vagrantFile = 'vagrantfile';

        $manifestConfiguration = ['manifest' => 'foo', 'server' => ['bashaliases' => $bashaliases]];
        $manifest = 'manifest';

        $readmeConfiguration = [
            'manifest' => 'foo',
            'server'   => ['bashaliases' => $bashaliases],
            'box'      => ['name' => 'baz']
        ];
        $readme = 'readme';

        $vagrantCompiler = $this->buildCompiler($vagrantConfiguration, $vagrantFile);
        $manifestCompiler = $this->buildCompiler($manifestConfiguration, $manifest);
        $readmeCompiler = $this->buildCompiler($readmeConfiguration, $readme);

        $domainFile = $this->getMockBuilder('Puphpet\Domain\File')
            ->disableOriginalConstructor()
            ->setMethods(['setName', 'createArchive'])
            ->getMock();

        $domainFile->expects($this->once())
            ->method('setName')
            ->with('baz.zip');

        $domainFile->expects($this->once())
            ->method('createArchive')
            ->with(
                [
                    'README'                                  => $readme,
                    'Vagrantfile'                             => $vagrantFile,
                    'manifests/default.pp'                    => $manifest,
                    'modules/puphpet/files/dot/.bash_aliases' => $bashaliases,
                ]
            );

        $configurator = $this->getMockBuilder(
            'Puphpet\Domain\Configurator\File\ConfiguratorHandler'
        )
            ->disableOriginalConstructor()
            ->setMethods(array())
            ->getMock();

        $generator = new Generator($vagrantCompiler, $manifestCompiler, $readmeCompiler, $domainFile, $configurator);
        $file = $generator->generateArchive(
            $boxConfiguration,
            $manifestConfiguration,
            $vagrantConfiguration
        );

        $this->assertInstanceOf('Puphpet\Domain\File', $file);
    }

    /**
     * @param array  $expectedConfiguration
     * @param string $will
     *
     * @return \PHPUnit_Framework_MockObject_MockObject
     */
    private function buildCompiler(array $expectedConfiguration, $will)
    {
        $mock = $this->getMockBuilder('Puphpet\Domain\Compiler\Compiler')
            ->disableOriginalConstructor()
            ->setMethods(['compile'])
            ->getMock();

        $mock->expects($this->once())
            ->method('compile')
            ->with($expectedConfiguration)
            ->will($this->returnValue($will));

        return $mock;
    }
}
