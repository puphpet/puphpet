<?php

namespace Puphpet\Tests\Domain\Configuration;

use Puphpet\Domain\Configuration\EditionProvider;

class EditionProviderTest extends \PHPUnit_Framework_TestCase
{
    public function testProvideUsesFallbackWhenEditionIsUnknown()
    {
        $availableEditions = [
            'default' => ['hello' => 'world'],
            'bar'     => ['some' => 'configuration']
        ];
        $defaultEditionName = 'default';

        $edition = $this->getMockBuilder('Puphpet\Domain\Configuration\Edition')
            ->disableOriginalConstructor()
            ->setMethods(['setName', 'setConfiguration'])
            ->getMock();
        $edition->expects($this->once())
            ->method('setName')
            ->with('default');
        $edition->expects($this->once())
            ->method('setConfiguration')
            ->with(['hello' => 'world']);


        $provider = new EditionProvider($edition, $availableEditions, $defaultEditionName);
        $provider->provide('unknown');
    }

    public function testProvideTakesValidEdition()
    {
        $availableEditions = [
            'default' => ['hello' => 'world'],
            'bar'     => ['some' => 'configuration']
        ];
        $defaultEditionName = 'default';

        $edition = $this->getMockBuilder('Puphpet\Domain\Configuration\Edition')
            ->disableOriginalConstructor()
            ->setMethods(['setName', 'setConfiguration'])
            ->getMock();
        $edition->expects($this->once())
            ->method('setName')
            ->with('bar');
        $edition->expects($this->once())
            ->method('setConfiguration')
            ->with(['some' => 'configuration']);

        $provider = new EditionProvider($edition, $availableEditions, $defaultEditionName);
        $provider->provide('bar');
    }
}
