<?php

namespace Puphpet\Tests\Unit\MainBundle\Extension;

use Puphpet\Tests\Unit;
use PuphpetBundle\Extension\Archive;

class ArchiveTest extends Unit\BaseTest
{
    /**
     * @var \PHPUnit_Framework_MockObject_MockObject|Archive
     */
    protected $archive;

    public function setUp()
    {
        $this->mock_archive = $this->getMockBuilder(Archive::class)
            ->setMethods(['exec', 'unlink', 'file_put_contents'])
            ->getMock();
        $this->archive = new Archive;
    }

    public function testgetSourceDir()
    {
        $this->assertFileExists($this->archive->getSourceDir());
    }

    public function testQueueToFileReturnsFalseOnNoEmptyFilename()
    {
        $this->assertFalse($this->archive->queueToFile('', ''));
    }

    public function testQueueToFileHoldsData()
    {
        $file1 = [
            'name'    => 'foobar',
            'content' => 'file1 content'
        ];
        $file2 = [
            'name'    => 'fizzbuzz',
            'content' => 'file2 content'
        ];
        $file3 = [
            'name'    => 'bizzbang',
            'content' => 'file3 content'
        ];
        $file4 = [
            'name'    => 'foobar',
            'content' => 'file4 content'
        ];

        $this->archive->queueToFile($file1['name'], $file1['content']);
        $this->archive->queueToFile($file2['name'], $file2['content']);
        $this->archive->queueToFile($file3['name'], $file3['content']);
        $this->archive->queueToFile($file4['name'], $file4['content']);

        $expectedResult = [
            $file1['name'] => "{$file1['content']}\n{$file4['content']}\n",
            $file2['name'] => "{$file2['content']}\n",
            $file3['name'] => "{$file3['content']}\n",
        ];

        $expectedArrayCount = count($expectedResult);

        $this->assertEquals($expectedResult, $this->archive->getFilesToWrite());

        $this->assertEquals($expectedArrayCount, count($this->archive->getFilesToWrite()));
    }

    public function testQueueToFileDoesntStoreEmptyFileData()
    {
        $emptyfile = [
            'name'    => '',
            'content' => NULL
        ];

        $this->assertFalse($this->archive->queueToFile($emptyfile['name'], $emptyfile['content']));
    }

    public function testWriteCalledFilePutContentsCorrectNumberOfTimes()
    {
        $file1 = [
            'name'    => 'foobar',
            'content' => 'file1 content'
        ];
        $file2 = [
            'name'    => 'fizzbuzz',
            'content' => 'file2 content'
        ];
        $file3 = [
            'name'    => 'bizzbang',
            'content' => 'file3 content'
        ];

        $this->mock_archive->expects($this->exactly(3))
            ->method('file_put_contents');

        $this->mock_archive->queueToFile($file1['name'], $file1['content']);
        $this->mock_archive->queueToFile($file2['name'], $file2['content']);
        $this->mock_archive->queueToFile($file3['name'], $file3['content']);

        $this->mock_archive->write();
    }

    public function testZipReturnsAZipFileLocation()
    {
        $file1 = [
            'name'    => 'foobar',
            'content' => 'file1 content'
        ];
        $file2 = [
            'name'    => 'fizzbuzz',
            'content' => 'file2 content'
        ];
        $file3 = [
            'name'    => 'bizzbang',
            'content' => 'file3 content'
        ];

        $this->mock_archive->expects($this->exactly(3))
            ->method('file_put_contents');

        $this->mock_archive->expects($this->once())
            ->method('exec');

        $targetDir = '/tmp/foobar';
        $baseDir = 'foobar';

        $this->setAttribute($this->mock_archive, 'targetDir', $targetDir);

        $exec = sprintf(
            Archive::ZIP_COMMAND,
            $targetDir,
            $targetDir . '.zip',
            $baseDir
        );

        $this->mock_archive->expects($this->once())
            ->method('exec')
            ->with($exec);

        $this->mock_archive->queueToFile($file1['name'], $file1['content']);
        $this->mock_archive->queueToFile($file2['name'], $file2['content']);
        $this->mock_archive->queueToFile($file3['name'], $file3['content']);

        $this->mock_archive->write();

        $returned = $this->mock_archive->zip();

        $this->assertEquals($targetDir . '.zip', $returned);
    }
}
