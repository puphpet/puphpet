<?php

namespace Puphpet\Tests\Serializer;

use Puphpet\Domain\Serializer\Cleaner;

class CleanerTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @dataProvider provideData
     */
    public function testCleanShouldRemovePasswordFields($deserialized, $expectedCleaned)
    {

        $cleaner = new Cleaner();
        $cleaned = $cleaner->clean($deserialized);

        $this->assertEquals($expectedCleaned, $cleaned);
    }

    static public function provideData()
    {
        return [
            [
                ['foo' => 'bar'],
                ['foo' => 'bar']
            ],
            [
                ['password' => 'bar'],
                ['password' => '<REMOVED>']
            ],
            [
                ['password' => '', 'foo' => 'bar'],
                ['password' => '', 'foo' => 'bar']
            ],
            [
                ['document_root' => 'baz', 'foo' => 'bar'],
                ['document_root' => 'baz', 'foo' => 'bar']
            ],
            [
                ['foo' => 'bar', 'sub1' => ['sub2' => ['_password' => 'sth', 'root' => 'bar']]],
                ['foo' => 'bar', 'sub1' => ['sub2' => ['_password' => '<REMOVED>', 'root' => '<REMOVED>']]],
            ],
        ];
    }


}
