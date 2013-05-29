<?php

namespace Puphpet\Tests\Controller;

use Puphpet\Tests\Base;

/**
 * @group functional
 */
class FrontTest extends Base
{
    public function testInitialPage()
    {
        $client = $this->createClient();
        $crawler = $client->request('GET', '/');

        // are we getting a 2xx?
        $this->assertTrue($client->getResponse()->isSuccessful());

        // default edition modules should be selected
        $this->assertCount(1, $crawler->filter('option[selected = \'selected\']:contains("php5-cli")'));
        $this->assertCount(1, $crawler->filter('option[selected = \'selected\']:contains("php5-curl")'));
        $this->assertCount(1, $crawler->filter('option[selected = \'selected\']:contains("php5-intl")'));
        $this->assertCount(1, $crawler->filter('option[selected = \'selected\']:contains("php5-mcrypt")'));
    }
}
