<?php

namespace PuphpetBundle\Extension;

use Puphpet\Tests\Unit\BaseTest;
use PuphpetBundle\Extension\Archive;
use PuphpetBundle\Twig\BaseExtension;

use RandomLib\Factory;

function error_log($msg)
{
    // this will be called instead of the native error_log() function
    echo "ERR: $msg";
}

class ReflectionTest extends BaseTest
{

    public function testArchiveExecFakeCMD()
    {
        $fakecmd = 'helloworld';

        $this->expectOutputString('ERR: Command not found: ' . $fakecmd);
        $this->assertEquals('', $this->invokeMethod(new Archive, 'exec', array($fakecmd)));
    }

    public function testGetAttribute()
    {
        $randomLib = new \RandomLib\Factory;
        $_randomLib = $this->getAttribute(new BaseExtension($randomLib), 'randomLib');
        $this->assertEquals($randomLib, $_randomLib);
    }

}
