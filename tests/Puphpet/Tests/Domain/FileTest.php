<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Domain\File;
use Puphpet\Tests\Base;

class FileTest extends Base
{
    protected $sysTempDir;
    protected $tmpFolder;
    protected $tmpPath;
    protected $archiveFile;

    public function setUp()
    {
        parent::setUp();

        $this->sysTempDir  = '/tmp';
        $this->tmpFolder   = '123abc';
        $this->tmpPath     = "{$this->sysTempDir}/{$this->tmpFolder}";
        $this->archiveFile = "{$this->sysTempDir}/{$this->tmpFolder}/tmpFile";
    }

    /**
     * @param string $constructorArgs Constructor arguments
     * @return \PHPUnit_Framework_MockObject_MockObject
     */
    protected function getFileMock($constructorArgs = '/path/to/folder/to/zip')
    {

        $file = $this->getMockBuilder('\Puphpet\Domain\File')
            ->setConstructorArgs([$constructorArgs])
            ->setMethods([
                'getSysTempDir',
                'getTmpFolder',
                'getTmpFile',
                'exec',
                'filePutContents',
                'readfile',
            ])
            ->getMock();

        $file->expects($this->once())
            ->method('getSysTempDir')
            ->will($this->returnValue($this->sysTempDir));

        $file->expects($this->once())
            ->method('getTmpFolder')
            ->will($this->returnValue($this->tmpFolder));

        $file->expects($this->once())
            ->method('getTmpFile')
            ->with($this->sysTempDir, $this->tmpFolder)
            ->will($this->returnValue($this->archiveFile));

        $file->expects($this->exactly(2))
            ->method('exec')
            ->with($this->logicalOr(
                 $this->equalTo("cp -r {$constructorArgs} {$this->tmpPath}"),
                 $this->equalTo("cd {$this->tmpPath} && zip -r {$this->archiveFile} * -x */.git\*")
             ));

        return $file;
    }

    public function testCreateArchiveDoesNotCallCopyFileOnNoReplacementFilesIdentified()
    {
        $file = $this->getFileMock();

        $file->expects($this->never())
            ->method('copyFile');

        $replacementFiles = array();

        $createdFile = $file->createArchive($replacementFiles);

        $this->assertEquals(
            $this->archiveFile,
            $createdFile
        );
    }

    public function testCreateArchiveCallsCopyFile()
    {
        $file = $this->getFileMock();

        $replacementFiles = [
            'replacement1' => 'foobar',
            'replacement2' => 'foobaz',
            'replacement3' => 'bambam',
        ];

        $file->expects($this->exactly(count($replacementFiles)))
            ->method('filePutContents')
            ->with($this->logicalOr(
                 $this->equalTo("{$this->tmpPath}/replacement1"), 'foobar',
                 $this->equalTo("{$this->tmpPath}/replacement2"), 'foobaz',
                 $this->equalTo("{$this->tmpPath}/replacement3"), 'bambam'
             ));

        $createdFile = $file->createArchive($replacementFiles);

        $this->assertEquals(
            $this->archiveFile,
            $createdFile
        );
    }
}
