<?php

namespace Puphpet\Tests\Domain\Configuration;

use Puphpet\Domain\Configuration\PropertyAccessProvider;

/**
 * @group integration
 */
class PropertyAccessProviderTest extends \PHPUnit_Framework_TestCase
{
    public function testProvideReturnsPropertyAccessor()
    {
        $provider = new PropertyAccessProvider();
        $accessor = $provider->provide();
        $this->assertInternalType('object', $accessor, 'accessor is from type object');
        $this->assertInstanceOf('\Symfony\Component\PropertyAccess\PropertyAccessorInterface', $accessor);
    }
}
